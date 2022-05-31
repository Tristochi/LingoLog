//
//  ViewController.swift
//  LingoLog
//
//  Created by Tristan Szakacs on 5/9/22.
//
/*
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

*/

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]

    @IBOutlet weak var signOutButton: UIButton!

    
    let signInButton = GIDSignInButton()
    private let service = GTLRYouTubeService()
    var theModel = VideoPlaylist()
    //let signOutButton = GIDSignOutButton()
    let output = UITextView()
    var playlistID = ""
    var vidID = ""
    var tempVidArray = [YTVideo]()
    

    @IBOutlet weak var loadDataBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        
        
        // Add the sign-in button.
        self.signOutButton.isHidden = true
        loadDataBtn.isHidden = true
        signInButton.center = view.center
        view.addSubview(signInButton)
        
        
        
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        //view.addSubview(output);
         
        
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            
            loadDataBtn.isHidden = false
            loadDataBtn.isEnabled = true
            //self.output.isHidden = false
            self.signOutButton.isHidden = false
            signOutButton.isEnabled = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            getChannelInfo()
            print("User email is " + user.profile.email)
            
        }
    }
    
    func getChannelInfo() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet,contentDetails")
        query.mine = true
        service.executeQuery(query, delegate: self, didFinish: #selector(
            completeChannelQuery(ticket:finishedWithObject:error:)))
    }
    
    @objc func completeChannelQuery(ticket: GTLRServiceTicket, finishedWithObject response: GTLRYouTube_ChannelListResponse, error: NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let channels = response.items, !channels.isEmpty {
            let channel = response.items![0]
            //Watch history not currently available so using liked vids
            //for now
            let playlistID = channel.contentDetails!.relatedPlaylists!.likes!
            
            getPlaylistInfo(playlistID: playlistID)

            
        }
    }
    
    func getPlaylistInfo(playlistID: String){
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: "snippet,contentDetails")
        query.playlistId = playlistID
        query.maxResults = 100
        print("Max results are \(query.maxResults)")
        //service.shouldFetchNextPages = true
        service.executeQuery(query, delegate: self, didFinish: #selector(completePlaylistQuery(ticket:finishedWithObject:error:)))
        
    }
    
    
    @objc func completePlaylistQuery(ticket:GTLRServiceTicket, finishedWithObject response: GTLRYouTube_PlaylistItemListResponse, error: NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let vids = response.items, !vids.isEmpty {
            //let vid = response.items![0]
            //let vidID = vid.contentDetails!.videoId!
            
            //getVidData(vidID: vidID)
            
            for vid in vids {
                vidID = vid.contentDetails!.videoId!
                getVidData(theVidID: vidID)
 
            }
            
        }
        
    }
    
    func getVidData(theVidID: String) {
        //I need to do a query for each vid ID and in the completion
        //make an obj for the vid and add it to the playlist array
        let query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet, contentDetails")
        query.identifier = vidID
        service.executeQuery(query, delegate: self, didFinish: #selector(completeVidDataQuery(ticket:finishedWithObject:error:)))
    }
    
    
    @objc func completeVidDataQuery(ticket:GTLRServiceTicket, finishedWithObject response: GTLRYouTube_VideoListResponse, error: NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if let vid = response.items, !vid.isEmpty {
            
            let vidDetails = response.items![0]
            
            var theVideo: YTVideo?

            if let theTitle = vidDetails.snippet?.title,
               let theLang = vidDetails.snippet?.defaultAudioLanguage,
               let theDuration = vidDetails.contentDetails?.duration{
            theVideo = YTVideo(vidTitle: theTitle, defaultAudioLanguage: LanguageCodes.langCodes.codes[theLang] ?? "English", duration: theDuration)
            }
            
            if(theVideo != nil){
                theModel.playlist.append(theVideo!)
            }
            
        }
        
    }


    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    /*
        IBAction Func
    */
    
    @IBAction func signOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        self.signOutButton.isHidden = true
        self.signInButton.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Something")
        //Run queries from API to fill Model with data
        
        
        //Pass model to TableViewController
        if let actualDest = segue.destination as? LangTableViewController {
            actualDest.theModel = theModel 
        }
        
        
    }

}
