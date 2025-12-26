#!/home/tom/.timewarrior/.venv/bin/python
import sys

from timewreport.parser import TimeWarriorParser

parser = TimeWarriorParser(sys.stdin)

totals = dict()

for interval in parser.get_intervals():
    tracked = interval.get_duration()

    for tag in interval.get_tags():
        if tag in totals:
            totals[tag] += tracked
        else:
            totals[tag] = tracked

# Determine largest tag width.
max_width = len("Total")

for tag in totals:
    if len(tag) > max_width:
        max_width = len(tag)

# Compose report header.
print("Total by Tag")
print("")

# Compose table header.
print("{:{width}} {:>10}".format("Tag", "TotalMin", width=max_width))
print("{} {}".format("-" * max_width, "----------"))

# Compose table rows.
grand_total = 0
for tag in sorted(totals):
    formatted = int(totals[tag].seconds / 60)
    print("{:{width}} {:10}".format(tag, formatted, width=max_width))
    grand_total += formatted

# Compose total.
print("{} {}".format(" " * max_width, "----------"))
print("{:{width}} {:10}".format("Total", grand_total, width=max_width))
