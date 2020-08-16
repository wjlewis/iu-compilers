use std::collections::HashMap;

pub struct SymbolTable {
    assocs: HashMap<String, u32>,
    names: Vec<String>,
    // Notice that there is no need to keep track of the next index to
    // be used, since this information is available as the length of the
    // `names` vector.
}

/// Names can be somewhat costly to compare and clone throughout the
/// compilation process. A `SymbolTable` allows us to work with
/// numerical aliases for names, saving time and memory. As an added
/// bonus, given a `SymbolTable` in which all names currently in use
/// have been interned, we can easily generate "fresh" names.
impl SymbolTable {
    pub fn new() -> SymbolTable {
        SymbolTable {
            assocs: HashMap::new(),
            names: Vec::new(),
        }
    }

    /// Add a new name to the symbol table, and return its index. If the
    /// name has already been interned, we return the original index.
    pub fn intern(&mut self, name: &str) -> u32 {
        match self.assocs.get(name) {
            Some(i) => *i,
            None => {
                let index = self.names.len() as u32;
                self.assocs.insert(name.to_owned(), index);
                self.names.push(name.to_owned());
                index
            }
        }
    }

    /// Return the name associated with the provided index if it has
    /// been interned in the table.
    pub fn lookup(&mut self, index: u32) -> Option<&str> {
        self.names.get(index as usize).map(|s| &s[..])
    }

    /// Generate a "fresh" (uninterned) name and return its index. The
    /// name will be generated from the hint but made unique by
    /// appending an appropriate numeral.
    /// *IMPORTANT* If a name is interned after this function is called,
    /// there are no guarantees that the generated name is still fresh.
    pub fn gensym(&mut self, hint: &str) -> u32 {
        let mut suffix = 1;
        let mut candidate = hint.to_owned();

        loop {
            if !self.assocs.contains_key(&candidate) {
                break;
            }

            candidate = format!("{}_{}", hint, suffix);
            suffix += 1;
        }

        self.intern(&candidate)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn intern() {
        let mut t = SymbolTable::new();

        let a1 = t.intern("a");
        let b1 = t.intern("b");
        let a2 = t.intern("a");
        let c1 = t.intern("c");

        assert_eq!(a1, a2);
        assert_ne!(a1, b1);
        assert_ne!(b1, c1);
        assert_ne!(a1, c1);
    }

    #[test]
    fn lookup() {
        let mut t = SymbolTable::new();

        let marmalade = t.intern("marmalade");
        let pancake = t.intern("pancake");

        assert_eq!(t.lookup(marmalade), Some("marmalade"));
        assert_eq!(t.lookup(pancake), Some("pancake"));
        assert_eq!(t.lookup(3), None);
    }

    #[test]
    fn gensym() {
        let mut t = SymbolTable::new();

        let squirrel = t.intern("squirrel");
        let squirrel1 = t.gensym("squirrel");
        let squirrel2 = t.gensym("squirrel");
        let panda = t.gensym("panda");

        assert_ne!(squirrel, squirrel1);
        assert_ne!(squirrel1, squirrel2);
        assert_ne!(squirrel, squirrel2);

        assert_eq!(t.lookup(squirrel1), Some("squirrel_1"));
        assert_eq!(t.lookup(squirrel2), Some("squirrel_2"));
        assert_eq!(t.lookup(panda), Some("panda"));
    }
}
