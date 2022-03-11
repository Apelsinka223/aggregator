# Aggregator

### Task Description
Your task is to build your very own airline API aggregator. When completed, your platform shall be able to return the cheapest flight offer from the NDC APIs of the two connected airlines, in response to a one-way flight search.  
When working on the task, please make sure that:  
● The resulting system is a JSON API with one single `/findCheapestOffer` endpoint.  
● When a GET request is sent to this endpoint with search details as query params, your aggregator shall trigger two concurrent HTTP GET requests to the two NDC APIs (called AirShoppingRQ in NDC terms).  
● After you received both responses, parse the XML responses.  
● Potentially both responses will have multiple offers (for multiple different flights, but that is
not important for this task).   
● Just look up the cheapest offer considering both lists of offers and return it to the client who made the original GET request to your Aggregator.  
Lastly, we want to make sure you don't waste time in setting up for this task, so in order to let you carry out this assessment, we have the sample NDC API responses of two real airlines: British Airways (code: BA) and Air France / KLM (codes: AFKL), you can use those to mock the actual APIs and its responses.  
Mock APIs:  
1. https://gist.githubusercontent.com/kanmaniselvan/bb11edf031e254977b210c480a0bd8 9a/raw/ea9bcb65ba4bb2304580d6202ece88aee38540f8/afklm_response_sample.xml  
2. https://gist.githubusercontent.com/kanmaniselvan/bb11edf031e254977b210c480a0bd8 9a/raw/ea9bcb65ba4bb2304580d6202ece88aee38540f8/ba_response_sample.xml  

## Prerequisites:  
* Set ENV variables for NDC url and auth token:  
  `NDC_BA_URL`, `NDC_BA_TOKEN`, `NDC_AFKLM_URL`, `NDC_AFKLM_TOKEN`
* Start server with `mix phx.server`
* Call `/findCheapestOffer` with parameters, 
e.g.: `/findCheapestOffer?origin=BER&destination=LHR&departureDate=2019-07-17`

### Examples
`http://localhost:4000/findCheapestOffer?origin=BER&destination=LHR&departureDate=2019-07-17`  
As you can see, three query parameters are needed:  
● airport code of the origin  
● airport code of the destination   
● departure date  

*Response JSON*  
`{data: {cheapestOffer: {amount: 55.19, airline: "BA"}}}`
