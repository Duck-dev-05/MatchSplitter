file = 'd:\\Code\\MatchSplitter\\Views\\SettlementView.swift'
with open(file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

count = 0
for i, line in enumerate(lines):
    l = line.split('//')[0]
    in_string = False
    clean_l = ''
    for char in l:
        if char == '\"':
            in_string = not in_string
        if not in_string:
            clean_l += char
    
    open_c = clean_l.count('{')
    close_c = clean_l.count('}')
    
    if open_c > 0 or close_c > 0:
        prev_count = count
        count += open_c - close_c
        print(f'{i+1:03d} | {prev_count:02d}->{count:02d} | {line.strip()}')
