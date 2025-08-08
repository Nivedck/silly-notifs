use std::env;
use std::process::Command;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: {} <governor>", args[0]);
        exit(1);
    }

    let governor = &args[1];

    // Only allow specific governors
    let allowed = ["performance", "powersave", "schedutil"];
    if !allowed.contains(&governor.as_str()) {
        eprintln!("Invalid governor: {}", governor);
        exit(1);
    }

    // Run cpupower frequency-set command
    let status = Command::new("/usr/bin/cpupower")
        .arg("frequency-set")
        .arg("-g")
        .arg(governor)
        .status()
        .expect("Failed to execute cpupower");

    if !status.success() {
        eprintln!("Failed to set governor: {}", governor);
        exit(1);
    }
}
