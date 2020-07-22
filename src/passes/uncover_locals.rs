use crate::c_0::*;
use crate::shared::symbol_table::SymbolTable;
use std::collections::HashSet;

impl C0 {
    pub fn uncover_locals(self) -> C0 {
        C0 {
            blocks: self
                .blocks
                .into_iter()
                .map(|b| Block {
                    locals: b.tail.uncover_locals(),
                    ..b
                })
                .collect(),
            syms: self.syms,
        }
    }
}

impl Tail {
    pub fn uncover_locals(&self) -> Vec<u32> {
        let mut locals = HashSet::new();

        self.stmts
            .iter()
            .for_each(|s| locals.extend(&s.collect_locals()));

        locals.extend(&self.result.collect_locals());

        locals.into_iter().collect()
    }
}

impl Stmt {
    pub fn collect_locals(&self) -> HashSet<u32> {
        match self {
            Stmt::Assign(i, e) => {
                let mut init: HashSet<u32> = [*i].iter().cloned().collect();
                init.extend(e.collect_locals());

                init
            }
        }
    }
}

impl Expr {
    pub fn collect_locals(&self) -> HashSet<u32> {
        match self {
            Expr::Arg(a) => a.collect_locals(),
            Expr::Read => HashSet::new(),
            Expr::Neg(a) => a.collect_locals(),
            Expr::Sum(l, r) => {
                let mut locals = l.collect_locals();
                locals.extend(r.collect_locals());
                locals
            }
        }
    }
}

impl Arg {
    pub fn collect_locals(&self) -> HashSet<u32> {
        match self {
            Arg::Name(i) => [*i].iter().cloned().collect(),
            _ => HashSet::new(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple() {
        let mut syms = SymbolTable::new();

        let a = syms.intern("a");
        let b = syms.intern("b");
        let c = syms.intern("c");
        let label = syms.intern("label");

        let prog = C0 {
            blocks: vec![Block {
                locals: vec![],
                label,
                tail: Tail::new(
                    vec![
                        Stmt::Assign(a, Expr::Sum(Arg::Num(3), Arg::Num(4))),
                        Stmt::Assign(b, Expr::Arg(Arg::Name(b))),
                        Stmt::Assign(c, Expr::Sum(Arg::Num(1), Arg::Name(b))),
                    ],
                    Expr::Neg(Arg::Name(c)),
                ),
            }],
            syms,
        };

        let locals: HashSet<u32> = prog
            .uncover_locals()
            .blocks
            .get(0)
            .unwrap()
            .locals
            .iter()
            .cloned()
            .collect();

        assert_eq!(
            locals,
            vec![a, b, c].iter().cloned().collect::<HashSet<u32>>()
        );
    }
}
