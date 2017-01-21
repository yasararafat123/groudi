class AnalyticsController < ApplicationController
	require 'pp'
	require 'descriptive_statistics'
	before_action :authenticate_user!
	before_filter :get_stablity
	skip_before_filter :get_stablity, :only => [:feedback]
	def show
		# @issue = Issue.find(params[:id])
		# @issue_attr = Standard.where(issue_id: params[:id]).order(id: :asc)
		# rand_users = Vote.uniq.pluck(:user_id).sample(5)
		# rand_users << current_user.id
		# pp rand_users
		# votes = Vote.where(issue_id: params[:id], user_id: rand_users ).order(column: :asc, row: :asc)
		# pp votes
		
		# @votes_hash = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
		# @aggregate_hash = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
		# variance_data = Array.new() { |i|  }

		# row_counter = 1
		# column_counter = 1
		# cell_values = Array.new() { |i|  }
		# points = Array.new() { |i|  }
		# @cell_variance = Array.new() { |i|  }
		# votes.each do | vote |
		# 	@votes_hash[vote.user_id][vote.column][vote.row] = vote
		# 	if @aggregate_hash[vote.column.to_s][vote.row.to_s].size>0
		# 		@aggregate_hash[vote.column.to_s][vote.row.to_s] += vote[:value]
		# 	else
		# 		@aggregate_hash[vote.column.to_s][vote.row.to_s] = vote[:value]
		# 	end
		# 	if row_counter==vote.row && column_counter == vote.column
		# 		cell_values << vote[:value]
		# 		column_counter = vote.column
		# 	else
		# 		variance_data.push(cell_values)
		# 		row_counter = vote.row
		# 		column_counter = vote.column
		# 		cell_values = []
		# 		cell_values << vote[:value]
		# 	end

		# 	if !points[vote.column-1]
		# 		points[vote.column-1] = vote.value*@issue_attr[vote.row-1].weight
		# 	else
		# 		points[vote.column-1] += vote.value*@issue_attr[vote.row-1].weight
		# 	end

		# end
		# variance_data.push(cell_values)

		# # variance calculation for each cell 
		# variance_data.each do | a |
		# 	# @cell_variance << a.variance.round(2)
		# 	@cell_variance << a.variance
		# end

		# # sensitivity calculation for the discussion
		
		# @stablity_cond_msg = ""
		# unstablities = 0
		# votes.each do | vote |
		# 	# if user had voted one more or one less point?
		# 	winner_set_add = points.dup
		# 	winner_set_dec = points.dup
		# 	winner_set_dec[vote.column-1] = winner_set_dec[vote.column-1] - @issue_attr[vote.row-1].weight
		# 	winner_set_add[vote.column-1] = winner_set_add[vote.column-1] + @issue_attr[vote.row-1].weight

		# 	if(winner_set_add.rindex(winner_set_add.max) != points.rindex(points.max) && vote.value < 5)
		# 		unstablities +=1
		# 		change_user = User.find(vote.user_id).email
		# 		# @stablity_cond_msg += "<code>" + change_user + " </code> increases vote by 1 on <code>" + @issue_attr[vote.row-1].title+ "/" + @issue[:idea][vote.column-1] + "</code>, new winner will be <code>"+ @issue[:idea][winner_set_add.rindex(winner_set_add.max)]+"</code><br> "
		# 	end
		# 	if(winner_set_dec.rindex(winner_set_dec.max) != points.rindex(points.max) && vote.value > 2)
		# 		unstablities +=1
		# 		change_user = User.find(vote.user_id).email
		# 		# @stablity_cond_msg += "<code>" + change_user + " </code> decreases vote by 1 on <code>" + @issue_attr[vote.row-1].title+ "/" + @issue[:idea][vote.column-1] + "</code>, new winner will be <code>"+ @issue[:idea][winner_set_dec.rindex(winner_set_dec.max)]+"</code><br> "
		# 	end
		# end
		# @stablity_percent = ((unstablities/votes.length.to_f)*100).ceil
		# @votes_hash.each do | key, value |
		# 	@votes_hash[key]["email"] = User.where(:id => key).select("email").first[:email]
		# end
		# pp "=============================================="
		# @comments = Comment.joins(:issue).where("comments.issue_id = "+params[:id]).order('grid ASC')
	end

	def feedback
		@stars = Like.where(creator: current_user.id).first
	end
	protected 
	def get_stablity
		@issue = Issue.find(params[:id])
		@issue_attr = Standard.where(issue_id: params[:id]).order(id: :asc)
		rand_users = Vote.uniq.pluck(:user_id).sample(5)
		rand_users << current_user.id
		pp rand_users
		votes = Vote.where(issue_id: params[:id], user_id: rand_users ).order(column: :asc, row: :asc)
		pp votes
		
		@votes_hash = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
		@aggregate_hash = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
		variance_data = Array.new() { |i|  }

		row_counter = 1
		column_counter = 1
		cell_values = Array.new() { |i|  }
		points = Array.new() { |i|  }
		@cell_variance = Array.new() { |i|  }
		votes.each do | vote |
			@votes_hash[vote.user_id][vote.column][vote.row] = vote
			if @aggregate_hash[vote.column.to_s][vote.row.to_s].size>0
				@aggregate_hash[vote.column.to_s][vote.row.to_s] += vote[:value]
			else
				@aggregate_hash[vote.column.to_s][vote.row.to_s] = vote[:value]
			end
			if row_counter==vote.row && column_counter == vote.column
				cell_values << vote[:value]
				column_counter = vote.column
			else
				variance_data.push(cell_values)
				row_counter = vote.row
				column_counter = vote.column
				cell_values = []
				cell_values << vote[:value]
			end

			if !points[vote.column-1]
				points[vote.column-1] = vote.value*@issue_attr[vote.row-1].weight
			else
				points[vote.column-1] += vote.value*@issue_attr[vote.row-1].weight
			end

		end
		variance_data.push(cell_values)

		# variance calculation for each cell 
		variance_data.each do | a |
			# @cell_variance << a.variance.round(2)
			@cell_variance << a.variance
		end

		# sensitivity calculation for the discussion
		
		@stablity_cond_msg = ""
		unstablities = 0
		votes.each do | vote |
			# if user had voted one more or one less point?
			winner_set_add = points.dup
			winner_set_dec = points.dup
			winner_set_dec[vote.column-1] = winner_set_dec[vote.column-1] - @issue_attr[vote.row-1].weight
			winner_set_add[vote.column-1] = winner_set_add[vote.column-1] + @issue_attr[vote.row-1].weight

			if(winner_set_add.rindex(winner_set_add.max) != points.rindex(points.max) && vote.value < 5)
				unstablities +=1
				change_user = User.find(vote.user_id).email
				@stablity_cond_msg += "<code>" + change_user + " </code> increases vote by 1 on <code>" + @issue_attr[vote.row-1].title+ "/" + @issue[:idea][vote.column-1] + "</code>, new winner will be <code>"+ @issue[:idea][winner_set_add.rindex(winner_set_add.max)]+"</code><br> "
			end
			if(winner_set_dec.rindex(winner_set_dec.max) != points.rindex(points.max) && vote.value > 2)
				unstablities +=1
				change_user = User.find(vote.user_id).email
				@stablity_cond_msg += "<code>" + change_user + " </code> decreases vote by 1 on <code>" + @issue_attr[vote.row-1].title+ "/" + @issue[:idea][vote.column-1] + "</code>, new winner will be <code>"+ @issue[:idea][winner_set_dec.rindex(winner_set_dec.max)]+"</code><br> "
			end
		end
		@stablity_percent = ((unstablities/votes.length.to_f)*100).ceil
		@votes_hash.each do | key, value |
			@votes_hash[key]["email"] = User.where(:id => key).select("email").first[:email]
		end
		pp "=============================================="
		@comments = Comment.joins(:issue).where("comments.issue_id = "+params[:id]).order('grid ASC')
	end

end

