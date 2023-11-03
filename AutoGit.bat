@echo off
set /p var=Enter commit:
echo your commit is:%var%  

git add .
git commit -m %var%
git push origin master

pause

