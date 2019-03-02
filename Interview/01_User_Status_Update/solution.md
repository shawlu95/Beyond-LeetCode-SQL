# User Status Update

### Given two tables:
* *AdDaily*: user_id (showing today paid ads fee) on day T
* *Advertiser*: two columns, user_id and their status on day T-1
Use today’s payment log in *AdDaily* table to update status in *Advertiser* table

### Status: 
* New: users registered on day T.
* Existing: users who paid on day T-1 and on day T.
* Churn: users who paid on day T-1 but not on day T.
* Resurrect: users who did not pay on T-1 but paid on day T.

### State Transition
| Start | End | Condition |
|----|----------|-----------|
|NEW|EXISTING|Paid on day T|
|NEW|CHURN|No pay on day T|
|EXISTING|EXISTING|Paid on day T|
|EXISTING|CHURN|No pay on day T|
|CHURN|RESURRECT|Paid on day T|
|CHURN|CHURN|No pay on day T|
|RESURRECT|EXISTING|Paid on day T|
|RESURRECT|CHURN|No pay on day T|

