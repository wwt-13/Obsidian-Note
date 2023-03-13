select * from
(select * from student_tb where sex='男') t1
left join
(select * from student_tb where sex='女') t2
on t1.birth=t2.birth and t1.name=t2.name;