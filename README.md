# Beyond LeetCode SQL
This repository covers supplementary analysis of SQL for LeetCode and classic interview questions, tradeoff between performance optimization and developmental efficiency, and how it relates to general database design consideration (e.g. indexing and join). Specific sample databases are provided to illustrate tricky interview questions.

### LeetCode catalogue
| \# | Problems | Solutions | Level | Concept |
|----|----------|-----------|------| --------|
| 262 | [Trips and Users](https://leetcode.com/problems/trips-and-users/) | [MySQL](./LeetCode/262_Trips_and_Users/README.md) | Hard | Three-way join; filtering |
| 185 | [Department Top Three Salaries](https://leetcode.com/problems/department-top-three-salaries) | [MySQL, MS SQL](./LeetCode/185_Department_Top_Three_Salaries/README.md) | Hard | Non-equijoin; aggregation; window function |
| 579 | [Cumulative Salary of Employee](https://leetcode.com/problems/find-cumulative-salary-of-an-employee/) | [MySQL, MS SQL](./LeetCode/579_Find_Cumulative_Salary_of_an_Employee/README.md) | Hard | Self-join; left join; aggregation | 
| 601 | [Human Traffic of Stadium](https://leetcode.com/problems/human-traffic-of-stadium/) | [MySQL, MS SQL](./LeetCode/601_Human_Traffic_of_Stadium/README.md) | Hard | Self-join; de-duplication; window |
| 615 | [Average Salary](https://leetcode.com/problems/average-salary-departments-vs-company/) | [MySQL](./LeetCode/615_Average_Salary/README.md) | Hard | Case; aggregation, join |
| 618 | [Students Report By Geography](https://leetcode.com/problems/students-report-by-geography/) | [MySQL, MS SQL](./LeetCode/618_Students_Report_by_Geography/README.md) | Hard | Full join, pivoting |

### Classic interview question
| \# | Problems | Solutions | Concept |
|----|----------|-----------|------|
| 1 | Facebook Advertiser Status | [MySQL](./Interview/01_Facebook_Advertiser_Status/README.md) | Transition diagram; conditional update|
| 2 | Spotify Listening History | [MySQL](./Interview/02_Spotify_Listening_History/README.md) | Update cumulative sum |
| 3 | Monthly Active User | [MySQL](./Interview/03_Monthly_Active_User/README.md) | Functional dependency; aggregation; filtering |
| 4 | Page Recommendation | [MySQL](./Interview/04_Page_Recommendation/README.md) | Undirected edge; aggregation; existance |

### Special Topics
| \# | Concept        | Notebook | 
|----|----------------|----------|
| 1  | Random Sampling from Groups      | [MySQL8](./Topics/random_sampling)   |
| 2  | NULL Pathological Study          | [MySQL8](./Topics/NULL_pathology)    |