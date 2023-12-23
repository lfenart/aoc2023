use std::collections::HashSet;
use std::io::{self, BufRead, BufReader};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    Top,
    Bottom,
    Left,
    Right,
}

impl Direction {
    fn delta(self) -> (isize, isize) {
        match self {
            Self::Top => (-1, 0),
            Self::Bottom => (1, 0),
            Self::Left => (0, -1),
            Self::Right => (0, 1),
        }
    }

    fn reverse(self) -> Self {
        match self {
            Self::Top => Self::Bottom,
            Self::Bottom => Self::Top,
            Self::Left => Self::Right,
            Self::Right => Self::Left,
        }
    }

    fn char(self) -> u8 {
        match self {
            Direction::Top => b'^',
            Direction::Bottom => b'v',
            Direction::Left => b'<',
            Direction::Right => b'>',
        }
    }
}

fn part1<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    let mut stack = vec![(1usize, 1usize, Direction::Top, 1)];
    let mut longest = 0;
    while let Some((x, y, dir, n)) = stack.pop() {
        for next_dir in [
            Direction::Top,
            Direction::Bottom,
            Direction::Left,
            Direction::Right,
        ] {
            if next_dir == dir {
                continue;
            }
            let (dx, dy) = next_dir.delta();
            let x = x.wrapping_add_signed(dx);
            if x >= lines.len() {
                longest = longest.max(n);
                continue;
            }
            let y = y.wrapping_add_signed(dy);
            let is_valid = match lines[x].as_ref()[y] {
                b'#' => false,
                b'.' => true,
                x => next_dir.char() == x,
            };
            if is_valid {
                stack.push((x, y, next_dir.reverse(), n + 1));
            }
        }
    }
    longest
}

fn part2<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    let mut stack = vec![(1usize, 1usize, Direction::Top, HashSet::new(), 1)];
    let mut longest = 0;
    let mut directions = Vec::with_capacity(3);
    while let Some((mut x, mut y, mut dir, mut visited, mut n)) = stack.pop() {
        loop {
            n += 1;
            directions.clear();
            directions.extend(
                [
                    Direction::Top,
                    Direction::Bottom,
                    Direction::Left,
                    Direction::Right,
                ]
                .into_iter()
                .filter_map(|next_dir| {
                    if next_dir == dir {
                        return None;
                    }
                    let (dx, dy) = next_dir.delta();
                    let x = x.wrapping_add_signed(dx);
                    let y = y.wrapping_add_signed(dy);
                    if lines[x].as_ref()[y] != b'#' {
                        Some((x, y, next_dir.reverse()))
                    } else {
                        None
                    }
                }),
            );
            if directions.len() != 1 {
                if visited.insert((x, y)) {
                    for &(x, y, dir) in directions.iter() {
                        stack.push((x, y, dir, visited.clone(), n));
                    }
                }
                break;
            }
            (x, y, dir) = directions[0];
            if x == lines.len() - 1 {
                longest = longest.max(n);
                break;
            }
        }
    }
    longest
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    println!("part2 = {}", part2(&lines));
    Ok(())
}
