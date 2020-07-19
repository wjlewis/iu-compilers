mod a_list;
mod eval;
mod expr;
mod symbol_table;

use expr::Term::*;
use symbol_table::SymbolTable;

fn main() {
    let e = expr::Expr {
        term: Sum(Box::new(Num(39)), Box::new(Read)),
        syms: SymbolTable::new(),
    };

    println!("{:?}", e.eval());
}
