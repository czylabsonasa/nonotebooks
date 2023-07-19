
function project_1_data()
	# read the data
	d0,h0=readdlm(
		"../data/synthetic_school_enrollment_data.csv",','; 
		header=true
	)
	# convert the original data
	
	# drop out the first three columns (name,major/minor)
	# and convert it to a valid logical matrix
	data=map(
		x->if x=="True"
			true
		elseif x=="False"
			false
		else
			throw(error("unknown value"))
		end, 
		d0[:,4:end]
	)
	
	header=h0[4:end]
	num_of_students,num_of_courses=size(data)

	# build the graph:
	# the nodes are the courses with an edge between them if there is a student visiting either.
	
	# first, collect the set of students visiting each courses
	S=[Set((1:num_of_students)[col]) for col in eachcol(data)]
	
	
	# then, use the sets
	G=Graph()
	add_vertices!(G,num_of_courses)
	for i in 1:num_of_courses-1, j in i+1:num_of_courses
		!isdisjoint(S[i],S[j]) && add_edge!(G,i,j)
	end
	(
		G=G,
		num_of_students=num_of_students,num_of_courses=num_of_courses,
		header=header
	)
end

