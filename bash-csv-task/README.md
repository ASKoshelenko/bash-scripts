# DevOps Essentials: Final task 1

## Bash Task 1

Company ABC has uncontrolled process of employee’s accounts creation. Currently process means
adding names, email and other personal data manually to the accounts.csv file without any rules.
Department head has decided to improve it based on the naming convention implementation. Good
idea for newcomers, but what to do with current user’s list? You have been asked to help. Could you please
develop automated way (bash script) and create new accounts_new.csv file based on current
accounts.csv and below.
1) Need to update column name.
Name format: first letter of name/surname uppercase and all other letters lowercase.
2) Need to update column email with domain @abc.
Email format: first letter from name and full surname, lowercase.
Equals emails should contain location_id.
3) Sripts should has name task1.sh
4) Path to accounts.csv file should be as argument to the script.
Definition of done.
Developed bash script which automatically creates accounts_new.csv and updates columns name and
email based on the rules above.

## Example:
```bash
./task1.sh accounts.csv
```
### was:
```csv
8,6,Bart charlow,Executive Director,,
9,7,Bart Charlow,Executive Director,,
```
### became:
```csv
8,6,Bart Charlow,Executive Director,bcharlow6@abc.com,
9,7,Bart Charlow,Executive Director,bcharlow7@abc.com,
```
