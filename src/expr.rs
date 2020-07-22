use crate::shared::symbol_table::SymbolTable;

pub struct Expr {
    pub term: Term,
    pub syms: SymbolTable,
}

#[derive(PartialEq, Debug)]
pub enum Term {
    Num(i32),
    Name(u32),
    Read,
    Sum(Box<Term>, Box<Term>),
    Neg(Box<Term>),
    Let(u32, Box<Term>, Box<Term>),
}
