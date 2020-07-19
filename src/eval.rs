use crate::a_list;
use crate::expr::{Expr, Term};
use std::io;

type Env = a_list::AList<u32, i32>;

impl Expr {
    pub fn eval(&self) -> Result<i32, &'static str> {
        self.term.eval(&mut Env::new())
    }
}

impl Term {
    pub fn eval(&self, env: &mut Env) -> Result<i32, &'static str> {
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
                env.extend(*i, tv);
                b.eval(env)
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
