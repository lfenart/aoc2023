use std::collections::HashSet;
use std::hash::Hash;
use std::io::{self, BufRead, BufReader};

use rand::Rng;

fn index<T: Eq + Hash>(subsets: &[HashSet<T>], item: &T) -> Option<usize> {
    subsets.iter().position(|s| s.contains(item))
}

fn part1<T: AsRef<str>>(lines: &[T]) -> u64 {
    let mut vertices = HashSet::new();
    let mut edges = Vec::new();
    for line in lines {
        let line = line.as_ref();
        let (key, values) = line.split_once(':').unwrap();
        let values = values.trim().split(' ').collect::<Vec<_>>();
        vertices.insert(key);
        for value in values {
            vertices.insert(value);
            edges.push((key, value));
        }
    }
    let mut rng = rand::thread_rng();
    let subsets = loop {
        let mut subsets = vertices
            .iter()
            .map(|&v| {
                let mut set = HashSet::new();
                set.insert(v);
                set
            })
            .collect::<Vec<_>>();
        while subsets.len() > 2 {
            let i = rng.gen_range(0, edges.len());
            let (s1, s2) = edges[i];
            let index2 = index(&subsets, &s2).unwrap();
            let index1 = index(&subsets, &s1).unwrap();
            if index1 != index2 {
                let s2 = subsets.remove(index2);
                let index1 = if index1 > index2 { index1 - 1 } else { index1 };
                subsets[index1].extend(s2);
            }
        }
        let count = edges
            .iter()
            .filter(|(u, v)| {
                let index = index(&subsets, u).unwrap();
                !subsets[index].contains(v)
            })
            .count();
        if count == 3 {
            break subsets;
        }
    };
    subsets.into_iter().map(|s| s.len() as u64).product()
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    Ok(())
}
