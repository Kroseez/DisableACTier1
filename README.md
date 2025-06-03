# Kroseez-DisableACTier1
The first part. Automate the locking of terminated employees' accounts in the active directory. Script PowerShell .PS1
The objective of this project is to implement a process that will automatically initiate the locking of accounts belonging to terminated employees in the active directory. 
In this particular script, the administrator must specify the path to the OU in which the accounts of terminated users are stored. 
The script performs an exhaustive check of all accounts in the OU and proceeds to disable them. 
Furthermore, a deactivation date for the account is created in the account settings in the "description" line.
