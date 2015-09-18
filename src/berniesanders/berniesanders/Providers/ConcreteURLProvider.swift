import Foundation

class ConcreteURLProvider : URLProvider {
    func issuesFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search?q=article_type:Issues&sort=created_at:desc&size=30")
    }
    
    func newsFeedURL() -> NSURL! {
        return NSURL(string: "https://search.berniesanders.tech/articles_en/berniesanders_com/_search?q=!article_type%3A(ExternalLink%20OR%20Issues)&sort=created_at:desc&size=30")
    }
    
    func bernieCrowdURL() -> NSURL! {
        return NSURL(string: "https://berniecrowd.org/")
    }
    
    
    func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "https://www.iubenda.com/privacy-policy/128001")
    }
}