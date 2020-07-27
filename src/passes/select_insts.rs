use crate::c_0::{self, Arg as CArg, Expr, Stmt, Tail, C0};
use crate::shared::symbol_table::SymbolTable;
use crate::x_86::{self, Arg, Inst, Reg, X86};

impl C0 {
    pub fn select_insts(self) -> X86 {
        let mut syms = self.syms;
        X86 {
            blocks: self
                .blocks
                .into_iter()
                .map(|b| b.into_x_86(&mut syms))
                .collect(),
        }
    }
}

impl c_0::Block {
    pub fn into_x_86(self, mut syms: &mut SymbolTable) -> x_86::Block {
        x_86::Block {
            locals: self.locals,
            label: self.label,
            insts: self.tail.into_insts(&mut syms),
        }
    }
}

impl Tail {
    pub fn into_insts(self, mut syms: &mut SymbolTable) -> Vec<Inst> {
        let mut insts: Vec<Inst> = Vec::new();

        self.stmts
            .into_iter()
            .for_each(|s| insts.append(&mut s.into_insts(&mut syms)));

        insts.append(&mut Expr::into_rax(self.result, &mut syms));
        insts.push(Inst::RetQ);
        insts
    }
}

impl Stmt {
    pub fn into_insts(self, mut syms: &mut SymbolTable) -> Vec<Inst> {
        match self {
            Stmt::Assign(i, e) => e.into_insts(i, &mut syms),
        }
    }
}

impl Expr {
    pub fn into_rax(result: Expr, syms: &mut SymbolTable) -> Vec<Inst> {
        match result {
            Expr::Arg(a) => match a {
                CArg::Num(n) => vec![Inst::MovQ(Arg::Int(n), Arg::Reg(Reg::Rax))],
                CArg::Name(i) => vec![Inst::MovQ(Arg::Var(i), Arg::Reg(Reg::Rax))],
            },
            Expr::Read => vec![Inst::CallQ(syms.intern("read_int"))],
            Expr::Neg(a) => match a {
                CArg::Num(n) => vec![
                    Inst::MovQ(Arg::Int(n), Arg::Reg(Reg::Rax)),
                    Inst::NegQ(Arg::Reg(Reg::Rax)),
                ],
                CArg::Name(i) => vec![
                    Inst::MovQ(Arg::Var(i), Arg::Reg(Reg::Rax)),
                    Inst::NegQ(Arg::Reg(Reg::Rax)),
                ],
            },
            Expr::Sum(a, b) => match a {
                CArg::Num(m) => match b {
                    CArg::Num(n) => vec![
                        Inst::MovQ(Arg::Int(m), Arg::Reg(Reg::Rax)),
                        Inst::AddQ(Arg::Int(n), Arg::Reg(Reg::Rax)),
                    ],
                    CArg::Name(j) => vec![
                        Inst::MovQ(Arg::Int(m), Arg::Reg(Reg::Rax)),
                        Inst::AddQ(Arg::Var(j), Arg::Reg(Reg::Rax)),
                    ],
                },
                CArg::Name(i) => match b {
                    CArg::Num(n) => vec![
                        Inst::MovQ(Arg::Var(i), Arg::Reg(Reg::Rax)),
                        Inst::AddQ(Arg::Int(n), Arg::Reg(Reg::Rax)),
                    ],
                    CArg::Name(j) => vec![
                        Inst::MovQ(Arg::Var(i), Arg::Reg(Reg::Rax)),
                        Inst::AddQ(Arg::Var(j), Arg::Reg(Reg::Rax)),
                    ],
                },
            },
        }
    }

    pub fn into_insts(self, lhs: u32, syms: &mut SymbolTable) -> Vec<Inst> {
        match self {
            Expr::Arg(i) => match i {
                CArg::Num(n) => vec![Inst::MovQ(Arg::Int(n), Arg::Var(lhs))],
                CArg::Name(j) => {
                    if lhs == j {
                        vec![]
                    } else {
                        vec![Inst::MovQ(Arg::Var(j), Arg::Var(lhs))]
                    }
                }
            },
            Expr::Read => vec![
                // Todo: Avoid repeated interning
                Inst::CallQ(syms.intern("read_int")),
                Inst::MovQ(Arg::Reg(Reg::Rax), Arg::Var(lhs)),
            ],
            Expr::Neg(a) => match a {
                CArg::Num(n) => vec![
                    Inst::MovQ(Arg::Int(n), Arg::Var(lhs)),
                    Inst::NegQ(Arg::Var(lhs)),
                ],
                CArg::Name(i) => {
                    if i == lhs {
                        vec![Inst::NegQ(Arg::Var(lhs))]
                    } else {
                        vec![
                            Inst::MovQ(Arg::Var(i), Arg::Var(lhs)),
                            Inst::NegQ(Arg::Var(lhs)),
                        ]
                    }
                }
            },
            Expr::Sum(a, b) => match a {
                CArg::Num(m) => match b {
                    CArg::Num(n) => vec![
                        Inst::MovQ(Arg::Int(m), Arg::Var(lhs)),
                        Inst::AddQ(Arg::Int(n), Arg::Var(lhs)),
                    ],
                    CArg::Name(i) => {
                        if i == lhs {
                            vec![Inst::AddQ(Arg::Int(m), Arg::Var(lhs))]
                        } else {
                            vec![
                                Inst::MovQ(Arg::Int(m), Arg::Var(lhs)),
                                Inst::AddQ(Arg::Var(i), Arg::Var(lhs)),
                            ]
                        }
                    }
                },
                CArg::Name(i) => match b {
                    CArg::Num(n) => {
                        if i == lhs {
                            vec![Inst::AddQ(Arg::Int(n), Arg::Var(lhs))]
                        } else {
                            vec![
                                Inst::MovQ(Arg::Var(i), Arg::Var(lhs)),
                                Inst::AddQ(Arg::Int(n), Arg::Var(lhs)),
                            ]
                        }
                    }
                    CArg::Name(j) => {
                        if i == lhs && j == lhs {
                            vec![Inst::AddQ(Arg::Var(lhs), Arg::Var(lhs))]
                        } else if i == lhs {
                            vec![Inst::AddQ(Arg::Var(j), Arg::Var(lhs))]
                        } else if j == lhs {
                            vec![Inst::AddQ(Arg::Var(i), Arg::Var(lhs))]
                        } else {
                            vec![
                                Inst::MovQ(Arg::Var(i), Arg::Var(lhs)),
                                Inst::AddQ(Arg::Var(j), Arg::Var(lhs)),
                            ]
                        }
                    }
                },
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple1() {
        let tail = Tail {
            stmts: vec![],
            result: Expr::Arg(CArg::Num(42)),
        };
        let mut syms = SymbolTable::new();

        assert_eq!(
            tail.into_insts(&mut syms),
            vec![Inst::MovQ(Arg::Int(42), Arg::Reg(Reg::Rax)), Inst::RetQ]
        );
    }

    #[test]
    fn simple2() {
        // x <- 3
        // y <- read
        // return x + y
        let tail = Tail {
            stmts: vec![
                Stmt::Assign(0, Expr::Arg(CArg::Num(3))),
                Stmt::Assign(1, Expr::Read),
            ],
            result: Expr::Sum(CArg::Name(0), CArg::Name(1)),
        };
        let mut syms = SymbolTable::new();

        assert_eq!(
            tail.into_insts(&mut syms),
            vec![
                Inst::MovQ(Arg::Int(3), Arg::Var(0)),
                Inst::CallQ(syms.intern("read_int")),
                Inst::MovQ(Arg::Reg(Reg::Rax), Arg::Var(1)),
                Inst::MovQ(Arg::Var(0), Arg::Reg(Reg::Rax)),
                Inst::AddQ(Arg::Var(1), Arg::Reg(Reg::Rax)),
                Inst::RetQ
            ]
        )
    }

    #[test]
    fn complex1() {
        // x <- 1
        // y <- 3
        // x <- x + y
        // y <- -y
        // return y + y
        let tail = Tail {
            stmts: vec![
                Stmt::Assign(0, Expr::Arg(CArg::Num(1))),
                Stmt::Assign(1, Expr::Arg(CArg::Num(3))),
                Stmt::Assign(0, Expr::Sum(CArg::Name(0), CArg::Name(1))),
                Stmt::Assign(1, Expr::Neg(CArg::Name(1))),
            ],
            result: Expr::Sum(CArg::Name(1), CArg::Name(1)),
        };
        let mut syms = SymbolTable::new();

        assert_eq!(
            tail.into_insts(&mut syms),
            vec![
                Inst::MovQ(Arg::Int(1), Arg::Var(0)),
                Inst::MovQ(Arg::Int(3), Arg::Var(1)),
                Inst::AddQ(Arg::Var(1), Arg::Var(0)),
                Inst::NegQ(Arg::Var(1)),
                Inst::MovQ(Arg::Var(1), Arg::Reg(Reg::Rax)),
                Inst::AddQ(Arg::Var(1), Arg::Reg(Reg::Rax)),
                Inst::RetQ
            ]
        )
    }
}
