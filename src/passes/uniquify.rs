use crate::expr::{Expr, Term};
use crate::shared::a_list::AList;
use crate::shared::symbol_table::SymbolTable;

impl Expr {
    pub fn uniquify(mut self) -> Result<Expr, &'static str> {
        let mut name_map = AList::new();
        self.term
            .uniquify(&mut self.syms, &mut name_map)
            .map(|term| Expr { term, ..self })
    }
}

impl Term {
    // We uniquify a term by processing its members recursively,
    // modifying the symbol table if necessary as we proceed.
    pub fn uniquify(
        &self,
        syms: &mut SymbolTable,
        name_map: &AList<u32, u32>,
    ) -> Result<Term, &'static str> {
        use Term::*;
        match self {
            Num(v) => Ok(Num(*v)),
            Name(i) => name_map.lookup(*i).ok_or("Unbound name").map(|&i| Name(i)),
            Read => Ok(Read),
            Sum(l, r) => l.uniquify(syms, name_map).and_then(|ul| {
                r.uniquify(syms, name_map)
                    .map(|ur| Sum(Box::new(ul), Box::new(ur)))
            }),
            Neg(t) => t.uniquify(syms, name_map).map(|ut| Neg(Box::new(ut))),
            Let(i, t, b) => {
                let j = match name_map.lookup(*i) {
                    // 1. We've already used this name before
                    // In this case, we must generate a fresh name and
                    // use it instead
                    Some(_) => {
                        let name = syms.lookup(*i).ok_or("Unbound name")?.to_owned();
                        Ok(syms.gensym(&name))
                    }
                    // 2. We haven't used this name yet
                    // Here we can just make a note of the association,
                    // and continue
                    None => Ok(*i),
                }?;
                let name_map = name_map.extend(*i, j);
                let t = t.uniquify(syms, &name_map)?;
                let b = b.uniquify(syms, &name_map)?;
                Ok(Let(j, Box::new(t), Box::new(b)))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use Term::*;

    #[test]
    fn nested_lets() {
        let mut syms = SymbolTable::new();
        let a = syms.intern("a");
        let b = syms.intern("b");

        // (let ([a 4])
        //   (let ([b a])
        //     (let ([a b])
        //       a)))
        let t = Let(
            a,
            Box::new(Num(4)),
            Box::new(Let(
                b,
                Box::new(Name(a)),
                Box::new(Let(a, Box::new(Name(b)), Box::new(Name(a)))),
            )),
        );

        // (let ([a 4])
        //   (let ([b a])
        //     (let ([a_1 b])
        //       a_1)))
        assert_eq!(
            t.uniquify(&mut syms, &AList::new()),
            Ok(Let(
                a,
                Box::new(Num(4)),
                Box::new(Let(
                    b,
                    Box::new(Name(a)),
                    Box::new(Let(2, Box::new(Name(b)), Box::new(Name(2))))
                ))
            ))
        )
    }

    #[test]
    fn inner_let() {
        let mut syms = SymbolTable::new();

        let a = syms.intern("a");

        // (let ([a (let ([a 42]) a)])
        //   (- a))
        let t = Let(
            a,
            Box::new(Let(a, Box::new(Num(42)), Box::new(Name(a)))),
            Box::new(Neg(Box::new(Name(a)))),
        );

        // (let ([a (let ([a_1 42]) a_1)])
        //   (- a))
        assert_eq!(
            t.uniquify(&mut syms, &AList::new()),
            Ok(Let(
                a,
                Box::new(Let(1, Box::new(Num(42)), Box::new(Name(1)),)),
                Box::new(Neg(Box::new(Name(a))))
            ))
        );
    }

    #[test]
    fn combined_lets() {
        let mut syms = SymbolTable::new();

        let a = syms.intern("a");

        // (+ (let ([a 3]) a)
        //    (let ([a 4]) a))
        let t = Sum(
            Box::new(Let(a, Box::new(Num(3)), Box::new(Name(a)))),
            Box::new(Let(a, Box::new(Num(4)), Box::new(Name(a)))),
        );

        // (+ (let ([a 3]) a)
        //    (let ([a 4]) a))
        assert_eq!(t.uniquify(&mut syms, &AList::new()), Ok(t));
    }
}
