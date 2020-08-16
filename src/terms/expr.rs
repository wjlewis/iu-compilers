use crate::common::symbol_table::SymbolTable;

pub struct FullExpr {
    pub names: SymbolTable,
    pub expr: Expr,
}

#[derive(PartialEq, Debug)]
pub enum Expr {
    Name(u32),
    Num(i32),
    Let(u32, Box<Expr>, Box<Expr>),
    Read,
    Neg(Box<Expr>),
    Sum(Box<Expr>, Box<Expr>),
}
