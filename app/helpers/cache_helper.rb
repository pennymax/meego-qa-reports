module CacheHelper

  def expire_index_for(test_session, release_version)
    expire_page :controller => 'index', :action => :index
    expire_page :controller => 'upload', :action => :upload_form
    expire_page :controller => 'index', :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype, :hwproduct => test_session.hwproduct, :release_version => release_version
    expire_page :controller => 'index', :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype, :release_version => release_version
    expire_page :controller => 'index', :action => :filtered_list, :target => test_session.target, :release_version => release_version
  end

  def expire_caches_for(test_session, release_version, results=false)
    route_params = {
        :controller => 'reports',
        :id => test_session.id,
        :action_suffix => 'test_results',
        :release_version => release_version,
        :target => test_session.target,
        :testtype => test_session.testtype,
        :hwproduct => test_session.hwproduct
    }

    %w{view print}.each do |action|
      expire_fragment route_params.merge(:action => action, :id => test_session.id)

      # TODO: Add expire_fragments here as well!
      if results
        prev_session = test_session.prev_session
        next_session = test_session.next_session

        expire_fragment route_params.merge(:action => action, :id => prev_session.id) if prev_session
        expire_fragment route_params.merge(:action => action, :id => next_session.id) if next_session

        next_session = next_session.try(:next_session)
        expire_fragment route_params.merge(:action => action, :id => next_session.id) if next_session
      end
    end
  end

end
