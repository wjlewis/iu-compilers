use crate::c_0::{Arg, Block, Expr as CExpr, Stmt, Tail, C0};
use crate::expr::{Expr, Term};
use crate::shared::symbol_table::SymbolTable;

impl Expr {
    pub fn explicate(mut self) -> C0 {
        C0 {
            // Just one block for now
            blocks: vec![Block {
                locals: vec![],
                label: self.syms.gensym("label"),
                tail: self.term.explicate(&mut self.syms),
            }],
            syms: self.syms,
        }
    }
}

impl Term {
    // Fix: Modify `Tail` to include an `Expr` instead of `Arg`
    pub fn explicate(&self, syms: &mut SymbolTable) -> Tail {
        use Term::*;

        match self {
            Num(v) => Tail::new(Vec::new(), CExpr::Arg(Arg::Num(*v))),
            Name(i) => Tail::new(Vec::new(), CExpr::Arg(Arg::Name(*i))),
            Read => {
                let tmp = syms.gensym("tmp");
                Tail::new(
                    vec![Stmt::Assign(tmp, CExpr::Read)],
                    CExpr::Arg(Arg::Name(tmp)),
                )
            }
            Sum(l, r) => {
                let l = l.explicate(syms);
                let mut r = r.explicate(syms);
                let mut stmts = l.stmts;
                stmts.append(&mut r.stmts);

                let mut la = l.result.argify(syms);
                let mut ra = r.result.argify(syms);

                stmts.append(&mut la.stmts);
                stmts.append(&mut ra.stmts);

                Tail::new(stmts, CExpr::Sum(la.result, ra.result))
            }
            Neg(t) => {
                let mut t = t.explicate(syms);
                let mut ta = t.result.argify(syms);

                t.stmts.append(&mut ta.stmts);

                Tail::new(t.stmts, CExpr::Neg(ta.result))
            }
            Let(i, t, b) => {
                let t = t.explicate(syms);
                let mut b = b.explicate(syms);
                let mut stmts = t.stmts;

                stmts.push(Stmt::Assign(*i, t.result));
                stmts.append(&mut b.stmts);

                Tail::new(stmts, b.result)
            }
        }
    }
}

impl CExpr {
    pub fn argify(self, syms: &mut SymbolTable) -> ArgTail {
        match self {
            CExpr::Arg(a) => ArgTail::new(Vec::new(), a),
            CExpr::Read => {
                let tmp = syms.gensym("tmp");
                ArgTail::new(vec![Stmt::Assign(tmp, CExpr::Read)], Arg::Name(tmp))
            }
            CExpr::Neg(a) => {
                let tmp = syms.gensym("tmp");
                ArgTail::new(vec![Stmt::Assign(tmp, CExpr::Neg(a))], Arg::Name(tmp))
            }
            CExpr::Sum(l, r) => {
                let tmp = syms.gensym("tmp");
                ArgTail::new(vec![Stmt::Assign(tmp, CExpr::Sum(l, r))], Arg::Name(tmp))
            }
        }
    }
}

pub struct ArgTail {
    pub stmts: Vec<Stmt>,
    pub result: Arg,
}

impl ArgTail {
    pub fn new(stmts: Vec<Stmt>, result: Arg) -> ArgTail {
        ArgTail { stmts, result }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use Term::*;

    #[test]
    fn compound_arith() {
        // (+ (+ 3 2) (- 4))
        let t = Sum(
            Box::new(Sum(Box::new(Num(3)), Box::new(Num(2)))),
            Box::new(Neg(Box::new(Num(4)))),
        );

        // tmp_1 <- (+ 3 2)
        // tmp_2 <- (- 4)
        // tmp_3 <- (+ tmp_1 tmp_2)
        // tmp_3
        assert_eq!(
            t.explicate(&mut SymbolTable::new()),
            Tail::new(
                vec![
                    Stmt::Assign(0, CExpr::Sum(Arg::Num(3), Arg::Num(2))),
                    Stmt::Assign(1, CExpr::Neg(Arg::Num(4))),
                ],
                CExpr::Sum(Arg::Name(0), Arg::Name(1))
            )
        );
    }

    #[test]
    fn nested_lets() {
        let mut syms = SymbolTable::new();
        let y = syms.intern("y");
        let x1 = syms.intern("x_1");
        let x2 = syms.intern("x_2");

        // (let ([y (let ([x_1 20])
        //            (let ([x_2 22])
        //              (+ x_1 x_2)))])
        //   y)
        let t = Let(
            y,
            Box::new(Let(
                x1,
                Box::new(Num(20)),
                Box::new(Let(
                    x2,
                    Box::new(Num(22)),
                    Box::new(Sum(Box::new(Name(x1)), Box::new(Name(x2)))),
                )),
            )),
            Box::new(Name(y)),
        );

        // x_1 <- 20
        // x_2 <- 22
        // y <- (+ x_1 x_2)
        // y
        assert_eq!(
            t.explicate(&mut syms),
            Tail::new(
                vec![
                    Stmt::Assign(x1, CExpr::Arg(Arg::Num(20))),
                    Stmt::Assign(x2, CExpr::Arg(Arg::Num(22))),
                    Stmt::Assign(y, CExpr::Sum(Arg::Name(x1), Arg::Name(x2))),
                ],
                CExpr::Arg(Arg::Name(y))
            )
        )
    }
}
