//
//  HtmlDownloader.swift
//  Picture Downloader
//
//  Created by Holger Hinzberg on 01.03.21.
//

import Cocoa

enum NetworkError: Error {
    case badURL, dataTaskFailed, requestFailed, unknown
}

class HtmlDownloader: NSObject
{
    private var dataTask: URLSessionDataTask? // For HTTP Get, HTML Source
    private let defaultSession = URLSession(configuration: .default)
    
    func validate(string:String?) -> (isValid:Bool, url:URL?)
    {
        guard let urlString = string else {return (false, nil)}
        guard let url = URL(string: urlString) else {return (false, nil)}
        return (true, url)
        /*
         let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
         let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
         
         if predicate.evaluate(with: string) == true
         {
         return (true, url)
         }
         return (false, nil)
         */
    }
    
    public func downloadAsync(url:URL, completion: @escaping (Result<String, NetworkError> ) -> Void )
    {
        dataTask?.cancel()
        
        dataTask = defaultSession.dataTask(with: url)
        {
            data, response, error in
            
            if let error = error
            {
                print(error.localizedDescription)
                DispatchQueue.main.async() {
                    completion(.failure(.dataTaskFailed))
                }
            }
            
            if data != nil
            {
                let buffer = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if let htmlSource = buffer {
                    DispatchQueue.main.async() {
                        completion(.success(htmlSource as String))
                    }
                }
            }
        }
        dataTask?.resume()
    }
}
