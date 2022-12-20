import sys
from github import Github
import time

body_str = ""
with open(sys.argv[2]) as f:
	body_str = f.readlines()

g = Github(sys.argv[1])
repo = g.get_repo("xermicus/fuzzy-sol")

title_str = "compile crash"
tid = "thread 'main' "
for line in body_str:
	if tid in line:
		title_str = line[len(tid):]


l = [repo.get_label("bug"), repo.get_label("substrate"), repo.get_label("scrap")]
print(repo.create_issue(title=title_str, body="".join(body_str), labels=l))

time.sleep(15)

