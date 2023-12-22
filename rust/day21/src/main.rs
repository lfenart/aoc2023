use std::collections::HashSet;
use std::io::{self, BufRead, BufReader};

const STEPS: u64 = 64;

fn part1<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    let mut grid = lines
        .iter()
        .map(|line| line.as_ref().to_vec())
        .collect::<Vec<_>>();
    let start_pos = (|| {
        for (i, line) in grid.iter().enumerate() {
            if let Some(j) = line.iter().position(|&x| x == b'S') {
                return (i, j);
            }
        }
        unreachable!()
    })();
    let mut positions = [start_pos].into_iter().collect::<HashSet<_>>();
    let mut sum = 1;
    for _ in 0..STEPS / 2 {
        for _ in 0..2 {
            let it = positions.into_iter();
            positions = HashSet::new();
            for (x, y) in it {
                if x > 0 && grid[x - 1][y] == b'.' {
                    positions.insert((x - 1, y));
                }
                if x + 1 < grid.len() && grid[x + 1][y] == b'.' {
                    positions.insert((x + 1, y));
                }
                if y > 0 && grid[x][y - 1] == b'.' {
                    positions.insert((x, y - 1));
                }
                if y + 1 < grid[x].len() && grid[x][y + 1] == b'.' {
                    positions.insert((x, y + 1));
                }
                for &(x, y) in positions.iter() {
                    grid[x][y] = b'#';
                }
            }
        }
        sum += positions.len() as u64;
    }
    sum
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    Ok(())
}
