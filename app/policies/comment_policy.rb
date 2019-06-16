class CommentPolicy < ApplicationPolicy
    def show?
        # can show a comment if you can show its ticket
        TicketPolicy.new(@user, record.ticket).show?
    end

    def update?
        # can update a comment if you created it
        @user == record.user
    end

    def destroy?
        # can destroy a comment if you created it
        @user == record.user
    end
end