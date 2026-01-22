import re

file_path = 'server/templates/dashboard.html'

with open(file_path, 'r') as f:
    content = f.read()

# Fix {{ }}
content = re.sub(r'\{\s+\{', '{{', content)
content = re.sub(r'\}\s+\}', '}}', content)

# Fix {% %}
content = re.sub(r'\{\s+\%', '{%', content)
content = re.sub(r'\%\s+\}', '%}', content)

# Fix < !-- -->
content = re.sub(r'<\s+!--', '<!--', content)

with open(file_path, 'w') as f:
    f.write(content)

print("Fixed template syntax.")
