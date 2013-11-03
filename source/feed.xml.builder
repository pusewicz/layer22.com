


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>middleman-blog/lib/middleman-blog/template/source/feed.xml.builder at master · middleman/middleman-blog · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="https://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <meta property="og:image" content="https://github.global.ssl.fastly.net/images/modules/logos_page/Octocat.png">
    <meta name="hostname" content="github-fe111-cp1-prd.iad.github.net">
    <meta name="ruby" content="ruby 1.9.3p194-tcs-github-tcmalloc (0e75de19f8) [x86_64-linux]">
    <link rel="assets" href="https://github.global.ssl.fastly.net/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035/">
    <link rel="xhr-socket" href="/_sockets" />
    


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="57C63DCB:6530:2A22B3E:5276C57F" name="octolytics-dimension-request_id" />
    

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="fw5IbN5KEqT6IDcWhK5gx3RXhS2mjcPDd+yas98xACg=" name="csrf-token" />

    <link href="https://github.global.ssl.fastly.net/assets/github-82d95d078b16fa64cfcabaff99138f5c59619266.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://github.global.ssl.fastly.net/assets/github2-b95518dadd9fd57d8fb892270da34baed14530c4.css" media="all" rel="stylesheet" type="text/css" />
    

    

      <script src="https://github.global.ssl.fastly.net/assets/frameworks-3d32afc910800ca0abfc4ed4357ed8a6f369f266.js" type="text/javascript"></script>
      <script src="https://github.global.ssl.fastly.net/assets/github-3ebcae34d9d5b6bd9a5bd8e3f5560c3692877177.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="6f6817f7edc3e64c7c6a02986ff4c698">

        <link data-pjax-transient rel='permalink' href='/middleman/middleman-blog/blob/02fdc98eff23aabebe27fafdf8dce1c69ad5870f/lib/middleman-blog/template/source/feed.xml.builder'>
  <meta property="og:title" content="middleman-blog"/>
  <meta property="og:type" content="githubog:gitrepository"/>
  <meta property="og:url" content="https://github.com/middleman/middleman-blog"/>
  <meta property="og:image" content="https://github.global.ssl.fastly.net/images/gravatars/gravatar-user-420.png"/>
  <meta property="og:site_name" content="GitHub"/>
  <meta property="og:description" content="middleman-blog - Blog engine for Middleman"/>

  <meta name="description" content="middleman-blog - Blog engine for Middleman" />

  <meta content="1280820" name="octolytics-dimension-user_id" /><meta content="middleman" name="octolytics-dimension-user_login" /><meta content="2237230" name="octolytics-dimension-repository_id" /><meta content="middleman/middleman-blog" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="2237230" name="octolytics-dimension-repository_network_root_id" /><meta content="middleman/middleman-blog" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/middleman/middleman-blog/commits/master.atom" rel="alternate" title="Recent Commits to middleman-blog:master" type="application/atom+xml" />

  </head>


  <body class="logged_out  env-production  vis-public  page-blob">
    <div class="wrapper">
      
      
      
      


      
      <div class="header header-logged-out">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions">
        <a class="button primary" href="/join">Sign up</a>
      <a class="button signin" href="/login?return_to=%2Fmiddleman%2Fmiddleman-blog%2Fblob%2Fmaster%2Flib%2Fmiddleman-blog%2Ftemplate%2Fsource%2Ffeed.xml.builder">Sign in</a>
    </div>

    <div class="command-bar js-command-bar  in-repository">

      <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
        <li class="features"><a href="/features">Features</a></li>
          <li class="enterprise"><a href="https://enterprise.github.com/">Enterprise</a></li>
          <li class="blog"><a href="/blog">Blog</a></li>
      </ul>
        <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    
      data-repo="middleman/middleman-blog"
      data-branch="master"
      data-sha="321683fec5f85b009b28399dbaa77789fcc317c1"
  >

    <input type="hidden" name="nwo" value="middleman/middleman-blog" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="octicon help tooltipped downwards" title="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
    </div>

  </div>
</div>


      


          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">


  <li>
  <a href="/login?return_to=%2Fmiddleman%2Fmiddleman-blog"
  class="minibutton with-count js-toggler-target star-button entice tooltipped upwards"
  title="You must be signed in to use this feature" rel="nofollow">
  <span class="octicon octicon-star"></span>Star
</a>
<a class="social-count js-social-count" href="/middleman/middleman-blog/stargazers">
  114
</a>

  </li>

    <li>
      <a href="/login?return_to=%2Fmiddleman%2Fmiddleman-blog"
        class="minibutton with-count js-toggler-target fork-button entice tooltipped upwards"
        title="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-git-branch"></span>Fork
      </a>
      <a href="/middleman/middleman-blog/network" class="social-count">
        82
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author">
            <a href="/middleman" class="url fn" itemprop="url" rel="author"><span itemprop="title">middleman</span></a>
          </span>
          <span class="repohead-name-divider">/</span>
          <strong><a href="/middleman/middleman-blog" class="js-current-repository js-repo-home-link">middleman-blog</a></strong>

          <span class="page-context-loader">
            <img alt="Octocat-spinner-32" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">

      <div class="repository-with-sidebar repo-container ">

        <div class="repository-sidebar">
            

<div class="sunken-menu vertical-right repo-nav js-repo-nav js-repository-container-pjax js-octicon-loaders">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped leftwards" title="Code">
        <a href="/middleman/middleman-blog" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-gotokey="c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /middleman/middleman-blog">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped leftwards" title="Issues">
          <a href="/middleman/middleman-blog/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-gotokey="i" data-selected-links="repo_issues /middleman/middleman-blog/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>11</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped leftwards" title="Pull Requests"><a href="/middleman/middleman-blog/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-gotokey="p" data-selected-links="repo_pulls /middleman/middleman-blog/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>2</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped leftwards" title="Pulse">
        <a href="/middleman/middleman-blog/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /middleman/middleman-blog/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Graphs">
        <a href="/middleman/middleman-blog/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /middleman/middleman-blog/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Network">
        <a href="/middleman/middleman-blog/network" aria-label="Network" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-selected-links="repo_network /middleman/middleman-blog/network">
          <span class="octicon octicon-git-branch"></span> <span class="full-word">Network</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

            <div class="only-with-full-nav">
              

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/middleman/middleman-blog.git" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/middleman/middleman-blog.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/middleman/middleman-blog" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/middleman/middleman-blog" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <span class="octicon help tooltipped upwards" title="Get help on which URL is right for you.">
    <a href="https://help.github.com/articles/which-remote-url-should-i-use">
    <span class="octicon octicon-question"></span>
    </a>
  </span>
</p>



              <a href="/middleman/middleman-blog/archive/master.zip"
                 class="minibutton sidebar-button"
                 title="Download this repository as a zip file"
                 rel="nofollow">
                <span class="octicon octicon-cloud-download"></span>
                Download ZIP
              </a>
            </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:36c07a5798276e66fc347ca4800dcd05 -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<a href="/middleman/middleman-blog/find/master" data-pjax data-hotkey="t" class="js-show-file-finder" style="display:none">Show File Finder</a>

<div class="file-navigation">
  
  

<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    role="button" aria-label="Switch branches or tags" tabindex="0">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax>

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-remove-close js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/blob/gemfile-consistency/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="gemfile-consistency"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="gemfile-consistency">gemfile-consistency</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/blob/master/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.4.1/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.4.1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.4.1">v3.4.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.4.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.4.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.4.0">v3.4.0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.3.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.3.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.3.0">v3.3.0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.2.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.2.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.2.0">v3.2.0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.1.1/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.1.1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.1.1">v3.1.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.1.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.1.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.1.0">v3.1.0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0.rc.4/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0.rc.4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0.rc.4">v3.0.0.rc.4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0.rc.3/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0.rc.3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0.rc.3">v3.0.0.rc.3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0.rc.2/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0.rc.2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0.rc.2">v3.0.0.rc.2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0.rc.1/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0.rc.1"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0.rc.1">v3.0.0.rc.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0.beta.3/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0.beta.3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0.beta.3">v3.0.0.beta.3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v3.0.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v3.0.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v3.0.0">v3.0.0</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v0.1.5/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v0.1.5"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v0.1.5">v0.1.5</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v0.1.4/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v0.1.4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v0.1.4">v0.1.4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v0.1.3/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v0.1.3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v0.1.3">v0.1.3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v0.1.2/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v0.1.2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v0.1.2">v0.1.2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/middleman/middleman-blog/tree/v0.1.0/lib/middleman-blog/template/source/feed.xml.builder"
                 data-name="v0.1.0"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="v0.1.0">v0.1.0</a>
            </div> <!-- /.select-menu-item -->
        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/middleman/middleman-blog" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">middleman-blog</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/middleman/middleman-blog/tree/master/lib" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">lib</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/middleman/middleman-blog/tree/master/lib/middleman-blog" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">middleman-blog</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/middleman/middleman-blog/tree/master/lib/middleman-blog/template" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">template</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/middleman/middleman-blog/tree/master/lib/middleman-blog/template/source" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">source</span></a></span><span class="separator"> / </span><strong class="final-path">feed.xml.builder</strong> <span class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="lib/middleman-blog/template/source/feed.xml.builder" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>



  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://1.gravatar.com/avatar/b7c3e74b81432a7559b09adaa0dceffe?d=https%3A%2F%2Fidenticons.github.com%2Fd0fb9ef9a33dcc25d270640691dd9f74.png&amp;r=x&amp;s=140" width="24" />
    <span class="author"><a href="/bhollis" rel="author">bhollis</a></span>
    <time class="js-relative-date" datetime="2013-09-16T22:30:30-07:00" title="2013-09-16 22:30:30">September 16, 2013</time>
    <div class="commit-title">
        <a href="/middleman/middleman-blog/commit/14b03ac79f3943b77dbb4d7b77a39ecfe6e7b3c8" class="message" data-pjax="true" title="Remove unnecessary guard from feed.xml.builder">Remove unnecessary guard from feed.xml.builder</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>5</strong> contributors</a></p>
          <a class="avatar tooltipped downwards" title="bhollis" href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder?author=bhollis"><img height="20" src="https://1.gravatar.com/avatar/b7c3e74b81432a7559b09adaa0dceffe?d=https%3A%2F%2Fidenticons.github.com%2Fd0fb9ef9a33dcc25d270640691dd9f74.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="rmm5t" href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder?author=rmm5t"><img height="20" src="https://2.gravatar.com/avatar/0f5f0ea6a2dc7ed3cb5830377a4fe7e2?d=https%3A%2F%2Fidenticons.github.com%2Fedfbe1afcf9246bb0d40eb4d8027d90f.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="jad" href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder?author=jad"><img height="20" src="https://1.gravatar.com/avatar/ecf53c0167dd8347a1b94f9840084499?d=https%3A%2F%2Fidenticons.github.com%2Fb2acf06f5459437420efd16f91c4b932.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="tdreyno" href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder?author=tdreyno"><img height="20" src="https://2.gravatar.com/avatar/291394b477c2824bf5d75b831f125304?d=https%3A%2F%2Fidenticons.github.com%2Fe165421110ba03099a1c0393373c5b43.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="barraponto" href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder?author=barraponto"><img height="20" src="https://2.gravatar.com/avatar/fa41d8fbd0879cee11da11ade94580b2?d=https%3A%2F%2Fidenticons.github.com%2F52c14983141f13c2b985cc89e437f096.png&amp;r=x&amp;s=140" width="20" /></a>


    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img height="24" src="https://1.gravatar.com/avatar/b7c3e74b81432a7559b09adaa0dceffe?d=https%3A%2F%2Fidenticons.github.com%2Fd0fb9ef9a33dcc25d270640691dd9f74.png&amp;r=x&amp;s=140" width="24" />
            <a href="/bhollis">bhollis</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://2.gravatar.com/avatar/0f5f0ea6a2dc7ed3cb5830377a4fe7e2?d=https%3A%2F%2Fidenticons.github.com%2Fedfbe1afcf9246bb0d40eb4d8027d90f.png&amp;r=x&amp;s=140" width="24" />
            <a href="/rmm5t">rmm5t</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://1.gravatar.com/avatar/ecf53c0167dd8347a1b94f9840084499?d=https%3A%2F%2Fidenticons.github.com%2Fb2acf06f5459437420efd16f91c4b932.png&amp;r=x&amp;s=140" width="24" />
            <a href="/jad">jad</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://2.gravatar.com/avatar/291394b477c2824bf5d75b831f125304?d=https%3A%2F%2Fidenticons.github.com%2Fe165421110ba03099a1c0393373c5b43.png&amp;r=x&amp;s=140" width="24" />
            <a href="/tdreyno">tdreyno</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://2.gravatar.com/avatar/fa41d8fbd0879cee11da11ade94580b2?d=https%3A%2F%2Fidenticons.github.com%2F52c14983141f13c2b985cc89e437f096.png&amp;r=x&amp;s=140" width="24" />
            <a href="/barraponto">barraponto</a>
          </li>
      </ul>
    </div>
  </div>

<div id="files" class="bubble">
  <div class="file">
    <div class="meta">
      <div class="info">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">file</span>
          <span>25 lines (23 sloc)</span>
        <span>0.965 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled js-entice" href=""
                 data-entice="You must be signed in to make or propose changes">Edit</a>
          <a href="/middleman/middleman-blog/raw/master/lib/middleman-blog/template/source/feed.xml.builder" class="button minibutton " id="raw-url">Raw</a>
            <a href="/middleman/middleman-blog/blame/master/lib/middleman-blog/template/source/feed.xml.builder" class="button minibutton ">Blame</a>
          <a href="/middleman/middleman-blog/commits/master/lib/middleman-blog/template/source/feed.xml.builder" class="button minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
          <a class="minibutton danger empty-icon js-entice" href=""
             data-entice="You must be signed in and on a branch to make or propose changes">
          Delete
        </a>
      </div><!-- /.actions -->

    </div>
        <div class="blob-wrapper data type-ruby js-blob-data">
        <table class="file-code file-diff">
          <tr class="file-code-line">
            <td class="blob-line-nums">
              <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>

            </td>
            <td class="blob-line-code">
                    <div class="highlight"><pre><div class='line' id='LC1'><span class="n">xml</span><span class="o">.</span><span class="n">instruct!</span></div><div class='line' id='LC2'><span class="n">xml</span><span class="o">.</span><span class="n">feed</span> <span class="s2">&quot;xmlns&quot;</span> <span class="o">=&gt;</span> <span class="s2">&quot;http://www.w3.org/2005/Atom&quot;</span> <span class="k">do</span></div><div class='line' id='LC3'>&nbsp;&nbsp;<span class="n">site_url</span> <span class="o">=</span> <span class="s2">&quot;http://blog.url.com/&quot;</span></div><div class='line' id='LC4'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">title</span> <span class="s2">&quot;Blog Name&quot;</span></div><div class='line' id='LC5'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">subtitle</span> <span class="s2">&quot;Blog subtitle&quot;</span></div><div class='line' id='LC6'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">id</span> <span class="no">URI</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="n">site_url</span><span class="p">,</span> <span class="n">blog</span><span class="o">.</span><span class="n">options</span><span class="o">.</span><span class="n">prefix</span><span class="o">.</span><span class="n">to_s</span><span class="p">)</span></div><div class='line' id='LC7'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">link</span> <span class="s2">&quot;href&quot;</span> <span class="o">=&gt;</span> <span class="no">URI</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="n">site_url</span><span class="p">,</span> <span class="n">blog</span><span class="o">.</span><span class="n">options</span><span class="o">.</span><span class="n">prefix</span><span class="o">.</span><span class="n">to_s</span><span class="p">)</span></div><div class='line' id='LC8'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">link</span> <span class="s2">&quot;href&quot;</span> <span class="o">=&gt;</span> <span class="no">URI</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="n">site_url</span><span class="p">,</span> <span class="n">current_page</span><span class="o">.</span><span class="n">path</span><span class="p">),</span> <span class="s2">&quot;rel&quot;</span> <span class="o">=&gt;</span> <span class="s2">&quot;self&quot;</span></div><div class='line' id='LC9'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">updated</span><span class="p">(</span><span class="n">blog</span><span class="o">.</span><span class="n">articles</span><span class="o">.</span><span class="n">first</span><span class="o">.</span><span class="n">date</span><span class="o">.</span><span class="n">to_time</span><span class="o">.</span><span class="n">iso8601</span><span class="p">)</span> <span class="k">unless</span> <span class="n">blog</span><span class="o">.</span><span class="n">articles</span><span class="o">.</span><span class="n">empty?</span></div><div class='line' id='LC10'>&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">author</span> <span class="p">{</span> <span class="n">xml</span><span class="o">.</span><span class="n">name</span> <span class="s2">&quot;Blog Author&quot;</span> <span class="p">}</span></div><div class='line' id='LC11'><br/></div><div class='line' id='LC12'>&nbsp;&nbsp;<span class="n">blog</span><span class="o">.</span><span class="n">articles</span><span class="o">[</span><span class="mi">0</span><span class="o">.</span><span class="n">.</span><span class="mi">5</span><span class="o">].</span><span class="n">each</span> <span class="k">do</span> <span class="o">|</span><span class="n">article</span><span class="o">|</span></div><div class='line' id='LC13'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">entry</span> <span class="k">do</span></div><div class='line' id='LC14'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">title</span> <span class="n">article</span><span class="o">.</span><span class="n">title</span></div><div class='line' id='LC15'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">link</span> <span class="s2">&quot;rel&quot;</span> <span class="o">=&gt;</span> <span class="s2">&quot;alternate&quot;</span><span class="p">,</span> <span class="s2">&quot;href&quot;</span> <span class="o">=&gt;</span> <span class="no">URI</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="n">site_url</span><span class="p">,</span> <span class="n">article</span><span class="o">.</span><span class="n">url</span><span class="p">)</span></div><div class='line' id='LC16'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">id</span> <span class="no">URI</span><span class="o">.</span><span class="n">join</span><span class="p">(</span><span class="n">site_url</span><span class="p">,</span> <span class="n">article</span><span class="o">.</span><span class="n">url</span><span class="p">)</span></div><div class='line' id='LC17'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">published</span> <span class="n">article</span><span class="o">.</span><span class="n">date</span><span class="o">.</span><span class="n">to_time</span><span class="o">.</span><span class="n">iso8601</span></div><div class='line' id='LC18'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">updated</span> <span class="no">File</span><span class="o">.</span><span class="n">mtime</span><span class="p">(</span><span class="n">article</span><span class="o">.</span><span class="n">source_file</span><span class="p">)</span><span class="o">.</span><span class="n">iso8601</span></div><div class='line' id='LC19'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">author</span> <span class="p">{</span> <span class="n">xml</span><span class="o">.</span><span class="n">name</span> <span class="s2">&quot;Article Author&quot;</span> <span class="p">}</span></div><div class='line' id='LC20'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="c1"># xml.summary article.summary, &quot;type&quot; =&gt; &quot;html&quot;</span></div><div class='line' id='LC21'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">xml</span><span class="o">.</span><span class="n">content</span> <span class="n">article</span><span class="o">.</span><span class="n">body</span><span class="p">,</span> <span class="s2">&quot;type&quot;</span> <span class="o">=&gt;</span> <span class="s2">&quot;html&quot;</span></div><div class='line' id='LC22'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">end</span></div><div class='line' id='LC23'>&nbsp;&nbsp;<span class="k">end</span></div><div class='line' id='LC24'><span class="k">end</span></div></pre></div>
            </td>
          </tr>
        </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2013 <span title="0.02105s from github-fe111-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/middleman/middleman-blog/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-remove-close close ajax-error-dismiss"></a>
      Something went wrong with that request. Please try again.
    </div>

  </body>
</html>

