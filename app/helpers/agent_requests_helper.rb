module AgentRequestsHelper
  def get_badges_agent_request_status(agent_request)
    case agent_request.status
    when 'pending'
      '<span class="badge text-bg-warning">Pendiente</span>'.html_safe
    when 'approved'
      '<span class="badge text-bg-success">Aprobada</span>'.html_safe
    when 'cancelled'
      '<span class="badge text-bg-secondary">Cancelada</span>'.html_safe
    else
      '<span class="badge text-bg-dark">Desconocido</span>'.html_safe
    end
  end
end