module UsersHelper
  def branch_options_for_select(companies)
    companies.flat_map do |company|
      if @current_branch
        ["#{@current_company.name} / #{@current_branch.name}", @current_branch.id]
      else
        company.branches.where(active: true).map do |branch|
          ["#{company.name} / #{branch.name}", branch.id]
        end
      end
    end
  end



end
