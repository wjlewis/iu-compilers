use std::rc::Rc;

#[derive(PartialEq, Debug)]
pub struct AList<K: PartialEq, V> {
    items: Rc<Items<K, V>>,
}

#[derive(PartialEq, Debug)]
enum Items<K: PartialEq, V> {
    Empty,
    Cons((K, V), Rc<Self>),
}

impl<K: PartialEq, V> AList<K, V> {
    pub fn new() -> Self {
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
    pub fn lookup(&self, key: K) -> Option<&V> {
        match self {
            Items::Empty => None,
            Items::Cons((k, v), next) => {
                if *k == key {
                    return Some(v);
                }
                next.lookup(key)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extend() {
        let l: AList<u32, i32> = AList::new();
        let l1 = l.extend(3, 42);
        let l11 = l1.extend(4, 10);
        let l12 = l1.extend(4, 561);
        let l2 = l.extend(3, 5);
        let l121 = l12.extend(3, 0);

        assert_eq!(l1.lookup(3), Some(&42));
        assert_eq!(l1.lookup(4), None);

        assert_eq!(l11.lookup(3), Some(&42));
        assert_eq!(l12.lookup(3), Some(&42));
        assert_eq!(l11.lookup(4), Some(&10));
        assert_eq!(l12.lookup(4), Some(&561));

        assert_eq!(l2.lookup(3), Some(&5));
        assert_eq!(l2.lookup(4), None);

        assert_eq!(l121.lookup(3), Some(&0));
        assert_eq!(l121.lookup(4), Some(&561));
    }
}
