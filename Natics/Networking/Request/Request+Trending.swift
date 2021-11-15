//
//  Request+Trending.swift
//  Natics
//
//  Created by Jackie Leonardy on 15/11/21.
//

import Foundation
import Combine


// Trending Request service information
struct TrendingProvinceRequest: Service {
    var baseUrl: String = Constants.Endpoint.databaseServer
    typealias Network = TrendingDescription
}

extension TrendingProvinceRequest: TrendingInterface {
    func getTrendingProvince(startDate: String, endDate: String) -> AnyPublisher<MCBaseResponse<TrendingProvinceGetResponse>, MCBaseErrorModel> {
        let call = Connector<Network, MCBaseResponse<TrendingProvinceGetResponse>>()
        return call.doConnect(request: Network.getTrendingProvince(startDate: startDate, endDate: endDate), baseUrl: baseUrl)
    }
}
