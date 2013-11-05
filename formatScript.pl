#!/usr/local/bin/perl

#grab the file name to user from arg list
$convFile = $ARGV[0];

print "Converting from input to CSV.";

#system command to convert input to .csv
## not sure why this is 'and die', and not 'or', but it didn't work right as 'or'
## might be something related to to system commands
system('unoconv', '-f', 'csv', $convFile)
	and die "Can't launch unoconv: $!";

print "Converting from CSV to LST\n";

#parse out the argument filename for use as a .csv
$convFile =~ /(.+)\.(.+)/;

#open the converted .csv using the naming from the recieved file
open(ROSTER, "$1.csv") and print "CSV opened successfully.\n" 
	or die "Could not find file";

#create and open .lst to be used as output
open(OUTPUT, ">$1.lst") and print "Output file created successfully.\n" 
	or die "Could not create output file.";

#for each: grabs a line from the .csv, and stores it in $line
for $line(<ROSTER>)
{
	#check to make sure that the line isn't a title column, very ugly right now
	unless($line =~ /^Name,/ )
	{
		#parse the line: last,first,ID,emailname,@emailserver,permission
		$line =~ /"(.+), (.+)",(\d{9}),(.+)(\@.+),(.+)/;
		#print line to output: ID,first,last,,,,,email,username
		print OUTPUT "$3,$1,$2,,,,,$4$5,$4";

		#make sure instructors have the right WW user level if imported
		if($6 =~ /Instructor/)
		{
			print OUTPUT ",,professor";
			#first field here is password, needs something
		}
		#get ready for next line
		print OUTPUT "\n";
	}
}

#adding users for grade proctor and login proctor
print OUTPUT "0000009,Proctor,Grade,,,,,,username,passowrd,userlevel";
print OUTPUT "0000008,Proctor,Login,,,,,,username,passowrd,userlevel";

#cleanup

#close file connections
close ROSTER;
close OUTPUT;

#delete the .csv file that was created by script
unlink "$1.csv";
