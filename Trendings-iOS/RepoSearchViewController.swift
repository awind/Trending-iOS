//
//  RepoSearchViewController.swift
//  Trending
//
//  Created by SongFei on 16/5/4.
//  Copyright © 2016年 SongFei. All rights reserved.
//

import UIKit
import SafariServices
import MJRefresh

class RepoSearchViewController: UITableViewController {
    
    let DEFAULT_CELL = "cell"
    let REPO_CELL = "searchRepoCell"
    
    var repos = [Repositiory]()
    
    var isLoading: Bool = false
    var currentPage = 1
    var totalCount = 10
    var keyword: String = "" {
        
        didSet{
            self.repos.removeAll()
            self.tableView.reloadData()
            currentPage = 1
            totalCount = 10
            self.tableView.mj_header.hidden = false
            self.tableView.mj_header.beginRefreshing()
        }
    }
    
    var parentNavigationController: UINavigationController?
    
    
    override func viewDidLoad() {
        
        tableView.registerNib(UINib(nibName: "SearchRepoCell", bundle: nil), forCellReuseIdentifier: REPO_CELL)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: DEFAULT_CELL)
        
        tableView.estimatedRowHeight = 138.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(pullDownRefresh))
        header.setTitle("Pull down to refresh", forState: .Idle)
        header.setTitle("Release to refresh", forState: .Pulling)
        header.setTitle("Loading", forState: .Refreshing)
        header.lastUpdatedTimeLabel?.hidden = true
        self.tableView.mj_header = header
    }
    
    func pullDownRefresh() {
        self.repos.removeAll()
        self.tableView.reloadData()
        currentPage = 1
        totalCount = 10
        searchRepos()
    }
    
}

extension RepoSearchViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let repo = repos[indexPath.row]
        let repoCell = tableView.dequeueReusableCellWithIdentifier(REPO_CELL, forIndexPath: indexPath) as! SearchRepoCell
        repoCell.bindItem(repo)
        return repoCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var svc: SFSafariViewController
        let repo = repos[indexPath.row]
        svc = SFSafariViewController(URL: NSURL(string: repo.url)!)
        self.parentNavigationController?.presentViewController(svc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.repos.count - 4 {
            fetchData()
        }
    }
    
    
    func fetchData() {
        if self.keyword.isEmpty {
            return
        }
        
        if isLoading {
            return
        }
        
        if currentPage * 10 > totalCount {
            return
        }
        
        isLoading = true
        searchRepos()
    }
    
    func searchRepos() {
        GitHubAPI.searchRepos(self.keyword, page: "\(currentPage)", completion: { items in
            self.isLoading = false
            self.tableView.mj_header.endRefreshing()
            if self.currentPage == 1 {
                self.repos.removeAll()
                self.repos = items.items
            } else {
                self.repos += items.items
            }
            self.currentPage += 1
            self.totalCount = items.count
            self.tableView.reloadData()
            }, fail:  { error in
                self.isLoading = false
        })
    }
    
    
}
