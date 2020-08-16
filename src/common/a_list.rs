use std::rc::Rc;

/// An `AList` -- short for "association list" -- is an ordered sequence
/// of pairs representing associations between keys and values. This
/// particular implementation  takes ownership of both keys and values.
pub struct AList<K: PartialEq, V> {
    items: Rc<Items<K, V>>,
}

enum Items<K: PartialEq, V> {
    Empty,
    Cons((K, V), Rc<Items<K, V>>),
}

impl<K: PartialEq, V> AList<K, V> {
    pub fn empty() -> Self {
        AList {
            items: Rc::new(Items::Empty),
        }
    }

    pub fn extend(&self, key: K, value: V) -> Self {
        AList {
            items: Rc::new(Items::Cons((key, value), Rc::clone(&self.items))),
        }
    }

    pub fn lookup(&self, key: K) -> Option<&V> {
        self.items.lookup(key)
    }
}

impl<K: PartialEq, V> Items<K, V> {
    fn lookup(&self, key: K) -> Option<&V> {
        match self {
            Items::Empty => None,
            Items::Cons((k, v), rest) => {
                if key == *k {
                    Some(v)
                } else {
                    rest.lookup(key)
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple_lookup() {
        let xs = AList::empty().extend("a", 1).extend("b", 2).extend("c", 3);

        assert_eq!(xs.lookup("a"), Some(&1));
        assert_eq!(xs.lookup("b"), Some(&2));
        assert_eq!(xs.lookup("c"), Some(&3));

        assert_eq!(xs.lookup("d"), None);
    }

    #[test]
    fn dup_lookup() {
        let xs = AList::empty()
            .extend("a", 42)
            .extend("b", 7)
            .extend("a", 561);

        assert_eq!(xs.lookup("a"), Some(&561));
    }
}
