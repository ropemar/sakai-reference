--SAK-21225 Extra Credit in Gradebook
Update GB_CATEGORY_T
set IS_EXTRA_CREDIT = 0
where IS_EXTRA_CREDIT is null

update GB_GRADABLE_OBJECT_T
Set IS_EXTRA_CREDIT = 0
Where IS_EXTRA_CREDIT is null

--END SAK-21225