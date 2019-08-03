# remember - when adding an action, add a corresponding
# method in ticket_policy.rb
class TicketsController < ApplicationController
  # authorize each action
  before_action :authorize_actions_on_one_ticket, except: [:index, :create, :assigned_tickets]

  before_action :set_ticket, only: [:show, :update, :destroy, :children, :tree]

  # verify each action is authorized
  after_action :verify_authorized, except: [:index, :create, :assigned_tickets]

  # GET /tickets
  def index
    @tickets = current_user.joined_tickets
  end

  # GET /assigned_tickets
  def assigned_tickets
    # Lists the tickets assigned to the current user
    @assigned_tickets = current_user.assigned_tickets
  end

  # GET /tickets/1
  def show
  end

  # POST /tickets
  def create
    # if you can't view an incident, you can't create tickets in it
    incident = Incident.find(ticket_params[:incident_id])
    raise Pundit::NotAuthorizedError unless IncidentPolicy.new(current_user, incident).show?

    @ticket = current_user.tickets.new(ticket_params)

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
      else
        format.html { redirect_to new_ticket_incident_url(incident), alert: 'Could not create ticket. Are you missing any required fields?' }
      end
    end
  end

  # PATCH/PUT /tickets/1
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :show }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
    end
  end
  
  # GET /tickets/1/children
  def children
      respond_to do |format|
        format.html { render :children }
      end
  end

  # GET /tickets/1/tree
  def tree
    gon.push({ ticket_tree_as_json: @ticket.to_json })

    respond_to do |format|
      format.html { render :tree }
    end
  end

  # GET /tickets/1/create_template
  def create_template
    @ticket.create_template
    respond_to do |format|
      format.html { redirect_to ticket_templates_url, notice: "Created template from ticket '#{@ticket}''"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
      @incident = @ticket.incident
    end

    def authorize_actions_on_one_ticket
      @ticket = Ticket.find(params[:id])
      authorize @ticket
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:name, :description, :incident_id, :is_lead, :status_id, :priority_id, :tag_list, :parent_id, :assigned_to_id)
    end
end
