#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from collections import defaultdict

def check_sequences(directory='.'):
    # Group files by basename pattern
    pattern = re.compile(r'^(.+?)(\d{4})(\.[^.]+)$')
    sequences = defaultdict(list)
    
    for f in Path(directory).iterdir():
        if not f.is_file():
            continue
        match = pattern.match(f.name)
        if match:
            base, frame, ext = match.groups()
            sequences[(base, ext)].append(int(frame))
    
    if not sequences:
        print("No sequences found")
        return 0
    
    all_passed = True
    for (base, ext), frames in sorted(sequences.items()):
        frames.sort()
        start, end = frames[0], frames[-1]
        expected = set(range(start, end + 1))
        actual = set(frames)
        missing = sorted(expected - actual)
        
        seq_name = f"{base}####{ext}"
        if missing:
            print(f"✗ {seq_name} [{start}-{end}]: MISSING {missing}")
            all_passed = False
        else:
            print(f"✓ {seq_name} [{start}-{end}]: OK ({len(frames)} frames)")
    
    return 0 if all_passed else 1

if __name__ == '__main__':
    sys.exit(check_sequences(sys.argv[1] if len(sys.argv) > 1 else '.'))