use std::io::{self, BufReader, Read};

fn part1(buf: &[u8]) -> u64 {
    let mut v = 0;
    let mut sum = 0;
    for &c in buf {
        if c == b',' {
            sum += v;
            v = 0;
            continue;
        }
        v = ((v + c as u64) * 17) % 256;
    }
    sum + v
}

fn part2(buf: &[u8]) -> u64 {
    let mut boxes: [_; 256] = std::array::from_fn(|_| Vec::new());
    for x in buf.split(|&c| c == b',') {
        let last = *x.last().unwrap();
        if last == b'-' {
            let key = &x[..x.len() - 1];
            let index = part1(key) as usize;
            let box_ = &mut boxes[index];
            if let Some(i) = box_.iter().position(|(item, _)| *item == key) {
                box_.remove(i);
            }
        } else {
            let key = &x[..x.len() - 2];
            let index = part1(key) as usize;
            let new_entry = (key, last - b'0');
            let box_ = &mut boxes[index];
            match box_.iter_mut().find(|(item, _)| *item == key) {
                Some(entry) => *entry = new_entry,
                None => box_.push(new_entry),
            }
        }
    }
    let mut sum = 0;
    for (i, box_) in boxes.into_iter().enumerate() {
        for (j, (_, focal_length)) in box_.into_iter().enumerate() {
            sum += (i as u64 + 1) * (j as u64 + 1) * focal_length as u64;
        }
    }
    sum
}

fn main() -> io::Result<()> {
    let mut reader = BufReader::new(std::io::stdin().lock());
    let mut buf = String::new();
    reader.read_to_string(&mut buf)?;
    let buf = buf
        .bytes()
        .filter(|&c| c != b'\n' && c != b'\r')
        .collect::<Vec<_>>();
    println!("part1 = {}", part1(&buf));
    println!("part2 = {}", part2(&buf));
    Ok(())
}
