use crate::common::a_list::AList;
use crate::common::symbol_table::SymbolTable;
use crate::terms::expr::*;

impl FullExpr {
    pub fn unshadow(mut self) -> Result<FullExpr, String> {
        let expr = self.expr.unshadow(&mut self.names, &AList::empty())?;
        Ok(FullExpr {
            names: self.names,
            expr,
        })
    }
}

impl Expr {
    pub fn unshadow(
        self,
        symbols: &mut SymbolTable,
        ctx: &AList<u32, u32>,
    ) -> Result<Expr, String> {
        use Expr::*;
        match self {
            Name(i) => ctx
                .lookup(i)
                .map(|&i| Name(i))
                // Note: this call to `unwrap` will panic if the index
                // in question isn't associated with a name.
                .ok_or(format!("Unbound name: \"{}\".", symbols.lookup(i).unwrap())),
            Num(v) => Ok(Num(v)),
            Let(i, e, b) => {
                // If the index `i` is already in use (in the context),
                // then all uses of the associated name in the body of
                // this `let` expression shadow the prior usage. To
                // "unshadow" these usages, we need to generate a fresh
                // name, and associate it with the index `i` in the
                // context.
                let e = e.unshadow(symbols, ctx)?;

                let j = match ctx.lookup(i) {
                    Some(_) => {
                        let name = symbols.lookup(i).unwrap();
                        let name = name.to_owned();
                        symbols.gensym(&name)
                    }
                    None => i,
                };

                let ctx = ctx.extend(i, j);
                let b = b.unshadow(symbols, &ctx)?;
                Ok(Let(j, Box::new(e), Box::new(b)))
            }
            Read => Ok(Read),
            Neg(e) => e.unshadow(symbols, ctx).map(|e| Neg(Box::new(e))),
            Sum(e1, e2) => {
                let e1 = e1.unshadow(symbols, ctx)?;
                let e2 = e2.unshadow(symbols, ctx)?;

                Ok(Sum(Box::new(e1), Box::new(e2)))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use Expr::*;

    #[test]
    fn unshadow_simple() {
        let mut t = SymbolTable::new();

        let a = t.intern("a");

        // (let ([a 4])
        //   (let ([a 42])
        //     a))
        let e = Let(
            a,
            Box::new(Num(4)),
            Box::new(Let(a, Box::new(Num(42)), Box::new(Name(a)))),
        );

        assert_eq!(
            e.unshadow(&mut t, &AList::empty()),
            Ok(Let(
                a,
                Box::new(Num(4)),
                Box::new(Let(1, Box::new(Num(42)), Box::new(Name(1))))
            ))
        );
    }

    #[test]
    fn unshadow_sum() {
        let mut t = SymbolTable::new();

        let a = t.intern("a");

        // (+ (let ([a 4]) a)
        //    (let ([a 2])
        //      (let ([a 6])
        //        (+ a (read)))))
        let e = Sum(
            Box::new(Let(a, Box::new(Num(4)), Box::new(Name(a)))),
            Box::new(Let(
                a,
                Box::new(Num(2)),
                Box::new(Let(
                    a,
                    Box::new(Num(6)),
                    Box::new(Sum(Box::new(Name(a)), Box::new(Read))),
                )),
            )),
        );

        assert_eq!(
            e.unshadow(&mut t, &AList::empty()),
            Ok(Sum(
                Box::new(Let(a, Box::new(Num(4)), Box::new(Name(a)))),
                Box::new(Let(
                    a,
                    Box::new(Num(2)),
                    Box::new(Let(
                        1,
                        Box::new(Num(6)),
                        Box::new(Sum(Box::new(Name(1)), Box::new(Read)))
                    ))
                ))
            ))
        )
    }
}
