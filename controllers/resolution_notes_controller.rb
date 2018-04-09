class ResolutionNotesController < ApplicationController
  # GET /resolution_notes/1
  # GET /resolution_notes/1.json
  def show
    @resolution_note = ResolutionNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resolution_note }
    end
  end

  # POST /resolution_notes
  # POST /resolution_notes.json
  def create
    @resolution_note = ResolutionNote.new(
      :user_id => params[:user_id],
      :fault_id => params[:fault_id],
      :note => params[:note]
    )
    respond_to do |format|
      if @resolution_note.save
        format.html { redirect_to @resolution_note, notice: 'resolution_note was successfully created.' }
        format.json { render json: @resolution_note, status: :created, location: @resolution_note }
      else
        format.html { render action: "new" }
        format.json { render json: @resolution_note.errors, status: :unprocessable_entity }
      end
    end
  end

end
