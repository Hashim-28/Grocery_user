import json
with open('machine_issues.txt', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()
    try:
        # flutter analyze --machine outputs some lines then a JSON string at the end. Or vice versa.
        # usually flutter analyze --machine just prints JSON. But we should just find lines that look like a json array.
        js = json.loads(text.split('\n[')[1].strip())
        js = '[' + text.split('\n[')[1].strip()
        data = json.loads(js)
    except:
        start = text.find('[')
        end = text.rfind(']') + 1
        data = json.loads(text[start:end])
    for e in data:
        if e['severity'] == 'ERROR':
            print(f"Error in {e['file']}:{e['line']}: {e['problemMessage']}")
