use std::collections::HashMap;
use std::io::{self, BufRead, BufReader};
use std::iter::zip;

fn part1<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    let mut columns_index = vec![0; lines[0].as_ref().len()];
    let mut sum = 0;
    for (i, line) in lines.iter().enumerate() {
        for (j, c) in line.as_ref().iter().enumerate() {
            match c {
                b'#' => {
                    columns_index[j] = i + 1;
                }
                b'O' => {
                    sum += (lines.len() - columns_index[j]) as u64;
                    columns_index[j] += 1;
                }
                _ => (),
            }
        }
    }
    sum
}

fn tilt_left(v: &mut [u8]) {
    let mut index = 0;
    for i in 0..v.len() {
        match v[i] {
            b'#' => index = i + 1,
            b'O' => {
                v[i] = b'.';
                v[index] = b'O';
                index += 1;
            }
            _ => (),
        }
    }
}

fn tilt_right(v: &mut [u8]) {
    let mut index = v.len();
    for i in (0..v.len()).rev() {
        match v[i] {
            b'#' => index = i,
            b'O' => {
                v[i] = b'.';
                index -= 1;
                v[index] = b'O';
            }
            _ => (),
        }
    }
}

fn count<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    lines
        .iter()
        .rev()
        .enumerate()
        .map(|(i, line)| (line.as_ref().iter().filter(|&&x| x == b'O').count() * (i + 1)) as u64)
        .sum()
}

fn north<T: AsRef<[u8]>>(
    platform: impl IntoIterator<Item = T>,
    col: usize,
) -> impl Iterator<Item = u8> {
    platform.into_iter().map(move |line| line.as_ref()[col])
}

fn part2<T: AsRef<[u8]>>(lines: &[T]) -> u64 {
    const MAX: u64 = 1000000000;
    let mut platform = lines
        .iter()
        .map(|line| line.as_ref().to_vec())
        .collect::<Vec<_>>();
    let width = platform[0].len();
    let mut map = HashMap::new();

    let mut i = 0;
    while i < MAX {
        // North
        for j in 0..width {
            let mut col = north(platform.iter(), j).collect::<Vec<_>>();
            tilt_left(&mut col);
            for (line, c) in zip(platform.iter_mut(), col) {
                line[j] = c;
            }
        }

        // West
        for row in platform.iter_mut() {
            tilt_left(row);
        }

        // South
        for j in 0..width {
            let mut col = north(platform.iter(), j).collect::<Vec<_>>();
            tilt_right(&mut col);
            for (line, c) in zip(platform.iter_mut(), col) {
                line[j] = c;
            }
        }

        // East
        for row in platform.iter_mut() {
            tilt_right(row);
        }

        if let Some(idx) = map.get(&platform) {
            let delta = i - idx;
            i += ((MAX - i) / delta) * delta;
        } else {
            map.insert(platform.clone(), i);
        }
        i += 1;
    }
    count(&platform)
}

fn main() -> io::Result<()> {
    let reader = BufReader::new(std::io::stdin().lock());
    let lines = reader.lines().collect::<io::Result<Vec<_>>>()?;
    println!("part1 = {}", part1(&lines));
    println!("part2 = {}", part2(&lines));
    Ok(())
}
