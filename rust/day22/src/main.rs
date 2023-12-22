use std::collections::HashSet;
use std::io::{self, BufRead, BufReader};

#[derive(Debug, Clone, Copy)]
struct Point {
    x: usize,
    y: usize,
    z: usize,
}

fn parse_point(s: &str) -> Point {
    let mut it = s.split(',');
    let x = it.next().unwrap().parse().unwrap();
    let y = it.next().unwrap().parse().unwrap();
    let z = it.next().unwrap().parse().unwrap();
    Point { x, y, z }
}

fn part1<T: AsRef<str>>(lines: &[T]) -> u64 {
    let mut bricks = lines
        .iter()
        .map(|line| {
            let line = line.as_ref();
            let (first, second) = line.split_once('~').unwrap();
            let first = parse_point(first);
            let second = parse_point(second);
            (first, second)
        })
        .collect::<Vec<_>>();
    let (xmax, ymax, zmax) = bricks.iter().fold((0, 0, 0), |(xmax, ymax, zmax), brick| {
        (
            xmax.max(brick.1.x),
            ymax.max(brick.1.y),
            zmax.max(brick.1.z),
        )
    });
    let mut grid = vec![vec![vec![usize::MAX; ymax + 1]; xmax + 1]; zmax + 1];
    bricks.sort_by_key(|(p1, _)| p1.z);
    let mut safe = vec![true; bricks.len()];
    let mut n = bricks.len();
    for (index, brick) in bricks.into_iter().enumerate() {
        let mut z = brick.0.z;
        let mut predecessors = HashSet::new();
        while z > 0 {
            for i in brick.0.x..=brick.1.x {
                for j in brick.0.y..=brick.1.y {
                    let toto = grid[z - 1][i][j];
                    if toto != usize::MAX {
                        predecessors.insert(toto);
                    }
                }
            }
            if !predecessors.is_empty() {
                if predecessors.len() == 1 {
                    let predecessor = predecessors.into_iter().next().unwrap();
                    if safe[predecessor] {
                        n -= 1;
                        safe[predecessor] = false;
                    }
                }
                break;
            }
            z -= 1;
        }
        for level in &mut grid[z..=z + brick.1.z - brick.0.z] {
            for line in &mut level[brick.0.x..=brick.1.x] {
                for cell in &mut line[brick.0.y..=brick.1.y] {
                    *cell = index;
                }
            }
        }
    }
    n as u64
}

fn part2<T: AsRef<str>>(lines: &[T]) -> u64 {
    let mut bricks = lines
        .iter()
        .map(|line| {
            let line = line.as_ref();
            let (first, second) = line.split_once('~').unwrap();
            let first = parse_point(first);
            let second = parse_point(second);
            (first, second)
        })
        .collect::<Vec<_>>();
    let (xmax, ymax, zmax) = bricks.iter().fold((0, 0, 0), |(xmax, ymax, zmax), brick| {
        (
            xmax.max(brick.1.x),
            ymax.max(brick.1.y),
            zmax.max(brick.1.z),
        )
    });
    let mut grid = vec![vec![vec![usize::MAX; ymax + 1]; xmax + 1]; zmax + 1];
    bricks.sort_by_key(|(p1, _)| p1.z);
    let mut holds = vec![HashSet::new(); bricks.len()];
    let mut is_held = vec![HashSet::new(); bricks.len()];
    for (index, brick) in bricks.into_iter().enumerate() {
        let mut z = brick.0.z;
        let mut predecessors = HashSet::new();
        while z > 0 {
            for i in brick.0.x..=brick.1.x {
                for j in brick.0.y..=brick.1.y {
                    let toto = grid[z - 1][i][j];
                    if toto != usize::MAX {
                        predecessors.insert(toto);
                    }
                }
            }
            if !predecessors.is_empty() {
                for &predecessor in predecessors.iter() {
                    holds[predecessor].insert(index);
                }
                is_held[index] = predecessors;
                break;
            }
            z -= 1;
        }
        for level in &mut grid[z..=z + brick.1.z - brick.0.z] {
            for line in &mut level[brick.0.x..=brick.1.x] {
                for cell in &mut line[brick.0.y..=brick.1.y] {
                    *cell = index;
                }
            }
        }
    }
    let mut count = 0;
    for i in 0..holds.len() {
        let mut removed = HashSet::new();
        let mut stack = vec![i];
        while let Some(x) = stack.pop() {
            if !removed.insert(x) {
                continue;
            }
            for &hold in holds[x].iter() {
                if is_held[hold].iter().all(|y| removed.contains(y)) {
                    stack.push(hold);
                }
            }
        }
        count += removed.len() as u64 - 1;
    }
    count
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    println!("part2 = {}", part2(&lines));
    Ok(())
}
