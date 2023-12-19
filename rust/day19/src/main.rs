use std::collections::HashMap;
use std::io::{self, BufRead, BufReader};

#[derive(Clone, Copy)]
enum Op {
    Lt,
    Gt,
}

impl Op {
    fn apply(&self, a: u64, b: u64) -> bool {
        match self {
            Op::Lt => a < b,
            Op::Gt => a > b,
        }
    }
}

struct Condition {
    variable: char,
    op: Op,
    value: u64,
    rule: String,
}

struct Rule {
    conditions: Vec<Condition>,
    default: String,
}

fn part1<T: AsRef<str>>(lines: &[T]) -> u64 {
    let mut it = lines.iter();
    let mut rules = HashMap::new();
    for line in it.by_ref() {
        let line = line.as_ref();
        if line.is_empty() {
            break;
        }
        let (rule_name, conditions) = line.split_once('{').unwrap();
        let conditions = conditions[..conditions.len() - 1]
            .split(',')
            .collect::<Vec<_>>();
        let mut list = Vec::new();
        for condition in &conditions[0..conditions.len() - 1] {
            let mut chars = condition.chars();
            let variable = chars.next().unwrap();
            let op = match chars.next().unwrap() {
                '>' => Op::Gt,
                '<' => Op::Lt,
                _ => panic!(),
            };
            let (value, rule) = chars.as_str().split_once(':').unwrap();
            let value = value.parse::<u64>().unwrap();
            list.push(Condition {
                variable,
                op,
                value,
                rule: rule.to_owned(),
            });
        }
        let default = *conditions.last().unwrap();
        rules.insert(
            rule_name,
            Rule {
                conditions: list,
                default: default.to_owned(),
            },
        );
    }
    let items = it
        .map(|line| {
            let line = line.as_ref();
            let mut map = HashMap::new();
            for it in line[1..line.len() - 1].split(',') {
                let mut chars = it.chars();
                let variable = chars.next().unwrap();
                chars.next().unwrap();
                let value = chars.as_str().parse::<u64>().unwrap();
                map.insert(variable, value);
            }
            map
        })
        .collect::<Vec<_>>();
    let mut sum = 0;
    for item in items {
        let mut rule_name = "in";
        'a: loop {
            let rule = rules.get(rule_name).unwrap();
            for condition in rule.conditions.iter() {
                if condition
                    .op
                    .apply(*item.get(&condition.variable).unwrap(), condition.value)
                {
                    match condition.rule.as_str() {
                        "A" => {
                            sum += item.values().sum::<u64>();
                            break 'a;
                        }
                        "R" => break 'a,
                        rule => {
                            rule_name = rule;
                            continue 'a;
                        }
                    }
                }
            }
            match rule.default.as_str() {
                "A" => {
                    sum += item.values().sum::<u64>();
                    break 'a;
                }
                "R" => break 'a,
                rule => {
                    rule_name = rule;
                }
            }
        }
    }
    sum
}

#[derive(Clone, Copy)]
struct Range {
    min: u64,
    max: u64,
}

impl Range {
    fn intersection(self, other: Self) -> Option<Self> {
        let min = self.min.max(other.min);
        let max = self.max.min(other.max);
        if max < min {
            return None;
        }
        Some(Range { min, max })
    }

    fn size(self) -> u64 {
        self.max + 1 - self.min
    }
}

fn part2<T: AsRef<str>>(lines: &[T]) -> u64 {
    let it = lines.iter();
    let mut rules = HashMap::new();
    for line in it {
        let line = line.as_ref();
        if line.is_empty() {
            break;
        }
        let (rule_name, conditions) = line.split_once('{').unwrap();
        let conditions = conditions[..conditions.len() - 1]
            .split(',')
            .collect::<Vec<_>>();
        let mut list = Vec::new();
        for condition in &conditions[0..conditions.len() - 1] {
            let mut chars = condition.chars();
            let variable = chars.next().unwrap();
            let op = match chars.next().unwrap() {
                '>' => Op::Gt,
                '<' => Op::Lt,
                _ => panic!(),
            };
            let (value, rule) = chars.as_str().split_once(':').unwrap();
            let value = value.parse::<u64>().unwrap();
            list.push(Condition {
                variable,
                op,
                value,
                rule: rule.to_owned(),
            });
        }
        let default = *conditions.last().unwrap();
        rules.insert(
            rule_name,
            Rule {
                conditions: list,
                default: default.to_owned(),
            },
        );
    }

    let mut stack = vec![(
        "in",
        [
            Range { min: 1, max: 4000 },
            Range { min: 1, max: 4000 },
            Range { min: 1, max: 4000 },
            Range { min: 1, max: 4000 },
        ],
    )];
    let mut sum = 0;
    while let Some((rule, mut ranges)) = stack.pop() {
        match rule {
            "A" => {
                sum += ranges.into_iter().map(Range::size).product::<u64>();
                continue;
            }
            "R" => continue,
            _ => (),
        }
        let rule = rules.get(rule).unwrap();
        for condition in rule.conditions.iter() {
            let (range_true, range_false) = match condition.op {
                Op::Lt => (
                    Range {
                        min: 1,
                        max: condition.value - 1,
                    },
                    Range {
                        min: condition.value,
                        max: 4000,
                    },
                ),
                Op::Gt => (
                    Range {
                        min: condition.value + 1,
                        max: 4000,
                    },
                    Range {
                        min: 0,
                        max: condition.value,
                    },
                ),
            };
            let index = match condition.variable {
                'x' => 0,
                'm' => 1,
                'a' => 2,
                's' => 3,
                _ => panic!(),
            };
            if let Some(r) = ranges[index].intersection(range_true) {
                let mut ranges = ranges;
                ranges[index] = r;
                stack.push((&condition.rule, ranges));
            }
            match ranges[index].intersection(range_false) {
                Some(r) => ranges[index] = r,
                None => break,
            }
        }
        stack.push((&rule.default, ranges));
    }
    sum
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    println!("part2 = {}", part2(&lines));
    Ok(())
}
