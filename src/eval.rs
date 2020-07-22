use crate::expr::{Expr, Term};
use crate::shared::a_list;
use std::io;

type Env = a_list::AList<u32, i32>;

impl Expr {
    pub fn eval(&self) -> Result<i32, &'static str> {
        self.term.eval(&Env::new())
    }
}

impl Term {
    pub fn eval(&self, env: &Env) -> Result<i32, &'static str> {
        use Term::*;
        match self {
            Num(v) => Ok(*v),
            // Todo: lookup name in symbol table
            Name(i) => env.lookup(*i).map(|&v| v).ok_or("Unbound name"),
            Read => read_i32(),
            Sum(l, r) => l
                .eval(env)
                .and_then(|lv| r.eval(env).and_then(|rv| Ok(lv + rv))),
            Neg(t) => t.eval(env).and_then(|v| Ok(-v)),
            Let(i, t, b) => t.eval(env).and_then(|tv| {
                let env = env.extend(*i, tv);
                b.eval(&env)
            }),
        }
    }
}

fn read_i32() -> Result<i32, &'static str> {
    let mut num = String::new();
    io::stdin()
        .read_line(&mut num)
        .map_err(|_| "Error reading input")
        .and_then(|_| num.trim().parse().map_err(|_| "Invalid number"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::shared::symbol_table::SymbolTable;
    use Term::*;

    #[test]
    fn simple_let() {
        let e = Expr {
            term: Let(
                0,
                Box::new(Sum(Box::new(Num(3)), Box::new(Num(4)))),
                Box::new(Neg(Box::new(Name(0)))),
            ),
            syms: SymbolTable::new(),
        };

        assert_eq!(e.eval(), Ok(-7));
    }

    #[test]
    fn nested_lets() {
        let e = Expr {
            term: Let(
                0,
                Box::new(Let(
                    0,
                    Box::new(Sum(Box::new(Num(39)), Box::new(Num(3)))),
                    Box::new(Name(0)),
                )),
                Box::new(Name(0)),
            ),
            syms: SymbolTable::new(),
        };

        assert_eq!(e.eval(), Ok(42));
    }

    #[test]
    fn unbound() {
        let e = Expr {
            term: Neg(Box::new(Sum(Box::new(Name(2)), Box::new(Num(3))))),
            syms: SymbolTable::new(),
        };

        assert_eq!(e.eval(), Err("Unbound name"));
    }
}
