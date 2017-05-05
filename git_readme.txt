HOW TO USE GIT
Read https://bitbucket.org/magnumsoftware/cware-repo/wiki/Workflow
 
1: https://bitbucket.org/magnumsoftware/cware-repo
2: Get clone link.
3: Execute clone command in git bash shell.
4: ./init_repo.sh in git bash shell.
5: git checkout -b R12CPU.447 origin/R12CPU.447
git checkout -b r12.x.581 origin/r12.x.581
git checkout -b r12.x.481 origin/r12.x.481
git checkout -b r12.x origin/r12.x
git checkout -b R12CPU.447.241 origin/R12CPU.447.241

#Back to 47 mainline
git checkout R12CPU.447
git checkout r12.x

6: git branch your_branch_name
7: git checkout your_branch_name
8: change code
9: git add .   (don't forget this".")
10: git commit
11: magnum_scripts/release_notes.py
12: git push origin your_branch_name
13: Build binary of your feature branch on http://jira-dev2.magnumsemi.com:8085/browse/CB-R12CPU/branches
14: Issue pull request: https://bitbucket.org/magnumsoftware/cware-repo/branch/R12CPU.447#pull-requests
15: Once the branch is reviewed,  please merge it : https://bitbucket.org/magnumsoftware/cware-repo/branch/R12CPU.447#pull-requests

Git:
#check tag version:
git tag
git describe
#Get latest version:
git fetch or git pull

dshan_R12-4867_x581v38_1008

#firstly 
git clone xxxxx
#Then 
git checkout tag_name
#to get the code corresponding to tag tag_name, when you'are warned a "detached HEAD" state, because tag is just a snapshot, you can't change the code, if you wanna to change the code, then you need to make a new branch based on this tag:
git checkout -b branch_name tag_name
#This will create a new branch based the tag, and then you can operate as before

15810758580

Build branch:
http://bamboo.magnumsemi.com/browse/CB-R12CPU/branches

CWARE_R12CPU.447_0350
dshan_1441_447x350_0830

#Force to delete branch
git branch -D xxxxx
#look up branch remote/all
git branch -r  		git branch -a
#How to delte remote branch
git push origin --delete <branchName>
git push --delete origin <branchName>
git push origin --delete tag <tagname>
#or
git push origin :<branchName>
git tag -d <tagname>
git push origin :refs/tags/<tagname>
#Rename local branch
git branch -m <oldbranchname> <newbranchname>

# Roll back to a commit
git reset --hard <commit_id>
# Roll back remote branch
git push origin HEAD --force
#########################################
#          Tag Operation
#########################################
# List tag
git tag
git tag -l 'V0.1.*'
# Tag a tag
git tag v0.1.2-light
git tag -a v0.1.2 -m 'Verstion 0.1'
#Tag on a commit
git tag -a v0.1.1 9fbc3d0
# Delete a tag
git tag -d v0.1.2
# Publish tag
git push origin v0.1.2
# Push all local tags
git push origin -tags

#Set user name/email address
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com 
git config user.email johndoe@example.com 
git config --list
git config --global --unset user.email

#error: you need to resolve your current index first
#Discard current merge
git reset --merge  
#Discard add new file or/and direcotry
git clean -f
git clean -df


#Set upstream branch
git branch --set-upstream debug origin/debug
