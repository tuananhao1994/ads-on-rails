module GoogleKeyword extend ActiveSupport::Concern
  def build_api_keywords(keywords_text, ad_group_id)
    keywords_text.map do |kwt|
      {
        :xsi_type => 'BiddableAdGroupCriterion',
        :ad_group_id => ad_group_id,
        :criterion => {
          :xsi_type => 'Keyword',
          :text => kwt,
          :match_type => 'BROAD'
        }
      }
    end
  end

  def add_keywords(keywords_text, ad_group_id, account_id)
    # get api service
    adwords = get_adwords_api
    ad_group_criterion_srv = adwords.service(:AdGroupCriterionService, get_api_version)

    # init api keywords
    keywords = build_api_keywords(keywords_text, ad_group_id)

    # create 'ADD' operations.
    operations = keywords.map do |keyword|
      {:operator => 'ADD', :operand => keyword}
    end

    # add keywords
    oci = adwords.credential_handler.credentials[:client_customer_id]
    adwords.credential_handler.set_credential(:client_customer_id, account_id)
    response = ad_group_criterion_srv.mutate(operations)
    adwords.credential_handler.set_credential(:client_customer_id, oci)
    
    # return result
    if response and response[:value]
      return response[:value]
    else
      raise StandardError, 'No keywords were added.'
    end
  end
end
