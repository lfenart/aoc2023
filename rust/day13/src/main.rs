use std::io::{self, BufRead, BufReader};
use std::iter::zip;

fn find(values: &[u64], smudges: u32) -> Option<usize> {
    'a: for (i, window) in values.windows(2).enumerate() {
        let (col1, col2) = if let [col1, col2, ..] = window {
            (col1, col2)
        } else {
            unreachable!()
        };
        let differences = (col1 ^ col2).count_ones();
        if differences <= smudges {
            let mut remaining = smudges - differences;
            let it1 = values[..i].iter().rev();
            let it2 = values[i + 2..].iter();
            for (a, b) in zip(it1, it2) {
                let ones = (a ^ b).count_ones();
                if ones > remaining {
                    continue 'a;
                }
                remaining -= ones;
            }
            if remaining == 0 {
                return Some(i + 1);
            }
        }
    }
    None
}

fn mirror(rows: &[u64], cols: &[u64], smudges: u32) -> Option<u64> {
    find(cols, smudges)
        .map(|x| x as u64)
        .or_else(|| find(rows, smudges).map(|x| (x as u64) * 100))
}

fn solve<T: AsRef<[u8]>>(lines: &[T], smudges: u32) -> Option<u64> {
    let mut rows = Vec::new();
    let mut cols = Vec::new();
    let mut sum = 0;
    for line in lines.iter().map(|x| x.as_ref()) {
        if line.is_empty() {
            sum += mirror(&rows, &cols, smudges)?;
            rows.clear();
            cols.clear();
            continue;
        }
        let mut row = 0;
        if cols.is_empty() {
            cols.resize(line.len(), 0);
        }
        for (i, &c) in line.iter().enumerate() {
            if c == b'#' {
                row += 1 << i;
                cols[i] += 1 << rows.len();
            }
        }
        rows.push(row);
    }
    if !rows.is_empty() {
        sum += mirror(&rows, &cols, smudges)?;
    }
    Some(sum)
}

fn part1<T: AsRef<[u8]>>(lines: &[T]) -> Option<u64> {
    solve(lines, 0)
}

fn part2<T: AsRef<[u8]>>(lines: &[T]) -> Option<u64> {
    solve(lines, 1)
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines).unwrap());
    println!("part2 = {}", part2(&lines).unwrap());
    Ok(())
}
