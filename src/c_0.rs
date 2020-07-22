use crate::shared::symbol_table::SymbolTable;

pub struct C0 {
    pub blocks: Vec<Block>,
    pub syms: SymbolTable,
}

#[derive(Debug, PartialEq)]
pub struct Block {
    pub locals: Vec<u32>,
    pub label: u32,
    pub tail: Tail,
}

#[derive(Debug, PartialEq)]
pub struct Tail {
    pub stmts: Vec<Stmt>,
    pub result: Expr,
}

impl Tail {
    pub fn new(stmts: Vec<Stmt>, result: Expr) -> Tail {
        Tail { stmts, result }
    }
}

#[derive(Debug, PartialEq)]
pub enum Stmt {
    Assign(u32, Expr),
}

#[derive(Debug, PartialEq)]
pub enum Expr {
    Arg(Arg),
    Read,
    Neg(Arg),
    Sum(Arg, Arg),
}

#[derive(Debug, PartialEq)]
pub enum Arg {
    Num(i32),
    Name(u32),
}
