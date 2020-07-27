pub struct X86 {
    pub blocks: Vec<Block>,
}

#[derive(Debug, PartialEq)]
pub struct Block {
    pub locals: Vec<u32>,
    pub label: u32,
    pub insts: Vec<Inst>,
}

#[derive(Debug, PartialEq)]
pub enum Inst {
    AddQ(Arg, Arg),
    SubQ(Arg, Arg),
    MovQ(Arg, Arg),
    RetQ,
    NegQ(Arg),
    CallQ(u32),
    PushQ(Arg),
    PopQ(Arg),
}

#[derive(Debug, PartialEq)]
pub enum Arg {
    // `Var` only belongs to "pseudo-x86"
    Var(u32),
    Int(i32),
    Reg(Reg),
    Deref(Reg, i32),
}

#[derive(Debug, PartialEq)]
pub enum Reg {
    Rsp,
    Rbp,
    Rax,
    Rbx,
    Rcx,
    Rdx,
    Rsi,
    Rdi,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
}
