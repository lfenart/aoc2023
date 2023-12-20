use std::collections::HashMap;
use std::io::{self, BufRead, BufReader};

enum ModuleType {
    FlipFlop,
    Conjunction,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Value {
    Low,
    High,
}

impl Value {
    fn flip(self) -> Self {
        match self {
            Value::Low => Value::High,
            Value::High => Value::Low,
        }
    }
}

#[derive(Clone, Debug)]
struct Module<'a> {
    inner: Option<ModuleInner<'a>>,
    connections: Vec<&'a str>,
}

impl<'a> Module<'a> {
    fn value(&self) -> Value {
        match &self.inner {
            Some(inner) => inner.value(),
            None => Value::Low,
        }
    }

    fn receive(&mut self, value: Value, from: &'a str) -> bool {
        if let Some(inner) = &mut self.inner {
            inner.receive(value, from)
        } else {
            true
        }
    }
}

#[derive(Clone, Debug)]
enum ModuleInner<'a> {
    FlipFlop(Value),
    Conjunction(HashMap<&'a str, Value>),
}

impl<'a> ModuleInner<'a> {
    fn receive(&mut self, value: Value, from: &'a str) -> bool {
        match self {
            ModuleInner::FlipFlop(v) => match value {
                Value::Low => {
                    *v = v.flip();
                    true
                }
                Value::High => false,
            },
            ModuleInner::Conjunction(m) => {
                m.insert(from, value);
                true
            }
        }
    }

    fn value(&self) -> Value {
        match self {
            ModuleInner::FlipFlop(v) => *v,
            ModuleInner::Conjunction(m) => {
                if m.iter().all(|(_, &x)| x == Value::High) {
                    Value::Low
                } else {
                    Value::High
                }
            }
        }
    }
}

fn part1<T: AsRef<str>>(lines: &[T]) -> u64 {
    let mut nexts = HashMap::new();
    let mut predecessors: HashMap<_, Vec<_>> = HashMap::new();
    for line in lines {
        let line = line.as_ref();
        let (module_name, connections) = line.split_once(" -> ").unwrap();
        let connections = connections.split(", ").collect::<Vec<_>>();
        let (module_type, module_name) = match module_name.as_bytes()[0] {
            b'%' => (Some(ModuleType::FlipFlop), &module_name[1..]),
            b'&' => (Some(ModuleType::Conjunction), &module_name[1..]),
            _ => (None, module_name),
        };
        for connection in connections.iter() {
            predecessors
                .entry(*connection)
                .or_default()
                .push(module_name);
        }
        nexts.insert(module_name, (connections, module_type));
    }

    let mut modules = nexts
        .into_iter()
        .map(|(name, (connections, typ))| {
            let inner = match typ {
                Some(ModuleType::FlipFlop) => Some(ModuleInner::FlipFlop(Value::Low)),
                Some(ModuleType::Conjunction) => Some(ModuleInner::Conjunction(
                    predecessors
                        .get(name)
                        .unwrap()
                        .iter()
                        .map(|&x| (x, Value::Low))
                        .collect(),
                )),
                None => None,
            };
            let module = Module { inner, connections };
            (name, module)
        })
        .collect::<HashMap<_, _>>();

    let max = 1000;
    let mut low = max;
    let mut high = 0;
    for _ in 0..max {
        let mut next = vec!["broadcaster"];
        while !next.is_empty() {
            let v = std::mem::take(&mut next);
            for x in v {
                let module = modules.remove(x).unwrap();
                let value = module.value();
                for c in module.connections.iter() {
                    match value {
                        Value::Low => low += 1,
                        Value::High => high += 1,
                    }
                    if let Some(m) = modules.get_mut(c) {
                        if m.receive(value, x) {
                            next.push(c);
                        }
                    }
                }
                modules.insert(x, module);
            }
        }
    }
    low * high
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    Ok(())
}
