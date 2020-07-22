use std::collections::HashMap;

#[derive(PartialEq, Debug)]
pub struct SymbolTable {
    assocs: HashMap<String, u32>,
    names: Vec<String>,
    next_index: u32,
}

impl SymbolTable {
    pub fn new() -> SymbolTable {
        SymbolTable {
            assocs: HashMap::new(),
            names: Vec::new(),
            next_index: 0,
        }
    }

    pub fn intern(&mut self, name: &str) -> u32 {
        match self.assocs.get(name) {
            Some(&i) => i,
            None => {
                self.assocs.insert(name.to_owned(), self.next_index);
                self.next_index += 1;
                self.names.push(name.to_owned());
                self.next_index - 1
            }
        }
    }

    pub fn lookup(&self, index: u32) -> Option<&str> {
        self.names.get(index as usize).map(|n| &n[..])
    }

    pub fn gensym(&mut self, hint: &str) -> u32 {
        let mut suffix = 1;
        let mut candidate = hint.to_owned();
        loop {
            match self.assocs.get(&candidate) {
                None => {
                    return self.intern(&candidate);
                }
                Some(_) => {
                    // Todo: don't allocate a new candidate each time around
                    candidate = format!("{}_{}", hint, suffix);
                    suffix += 1;
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn intern() {
        let mut tab = SymbolTable::new();

        let a0 = tab.intern("a");
        let b0 = tab.intern("b");
        let a1 = tab.intern("a");
        let a2 = tab.intern("a");
        let c0 = tab.intern("c");
        let c1 = tab.intern("c");
        let b1 = tab.intern("b");

        assert_eq!(a0, a1);
        assert_eq!(a0, a2);
        assert_eq!(b0, b1);
        assert_eq!(c0, c1);
    }

    #[test]
    fn lookup() {
        let mut tab = SymbolTable::new();

        let cucumber = tab.intern("cucumber");
        let radish = tab.intern("radish");

        assert_eq!(tab.lookup(cucumber), Some("cucumber"));
        assert_eq!(tab.lookup(radish), Some("radish"));
        assert_eq!(tab.lookup(42), None);
    }

    #[test]
    fn gensym() {
        let mut tab = SymbolTable::new();

        let tmp = tab.intern("tmp");
        let tmp1 = tab.gensym("tmp");
        tab.intern("string_bean");
        let tmp2 = tab.gensym("tmp");

        assert_ne!(tmp, tmp1);
        assert_ne!(tmp, tmp2);
        assert_ne!(tmp1, tmp2);

        assert_eq!(tab.lookup(tmp), Some("tmp"));
        assert_eq!(tab.lookup(tmp1), Some("tmp_1"));
        assert_eq!(tab.lookup(tmp2), Some("tmp_2"));
    }
}
