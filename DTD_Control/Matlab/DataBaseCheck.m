basedir = 'D:\HIWI\Test3\Final\DTD_Results';
database = sqlite(join([basedir,'\TestData\exp_database.db']));
sqlquery = join(['SELECT * FROM Person WHERE loginName = "',char(username),'"']);
result = fetch(database,sqlquery)
if size(result) == [0 0]
    un =0;
    uid = 0;
   User_name = "unknown";
else
    un = 1;
    uid = result{1,1};
    User_name = result{1,3};
end
%Impactor Check
sqlquery = join(['SELECT * FROM Impactor WHERE id = ',string(impactor_ID)]);
result = fetch(database,sqlquery)
if size(result) == [0 0]
    impactor = 0
else
    impactor = 1
end
%Subject Check
sqlquery = join(['SELECT ifnull(id,0) FROM TestSubject WHERE id = ',string(subject_ID)]);
result = fetch(database,sqlquery)
if size(result) == [0 0]
    subject = 0;
else
    subject = 1;
end
close(database);