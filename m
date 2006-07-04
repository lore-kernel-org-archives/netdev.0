From: Paul Jackson <pj@sgi.com>
Subject: Re: [Patch][RFC] Disabling per-tgid stats on task exit in taskstats
Date: Tue, 4 Jul 2006 13:19:13 -0700
Message-ID: <20060704131913.83a604a0.pj@sgi.com>
References: <44892610.6040001@watson.ibm.com>
	<449CAA78.4080902@watson.ibm.com>
	<20060623213912.96056b02.akpm@osdl.org>
	<449CD4B3.8020300@watson.ibm.com>
	<44A01A50.1050403@sgi.com>
	<20060626105548.edef4c64.akpm@osdl.org>
	<44A020CD.30903@watson.ibm.com>
	<20060626111249.7aece36e.akpm@osdl.org>
	<44A026ED.8080903@sgi.com>
	<20060626113959.839d72bc.akpm@osdl.org>
	<44A2F50D.8030306@engr.sgi.com>
	<20060628145341.529a61ab.akpm@osdl.org>
	<44A2FC72.9090407@engr.sgi.com>
	<20060629014050.d3bf0be4.pj@sgi.com>
	<200606291230.k5TCUg45030710@turing-police.cc.vt.edu>
	<20060629094408.360ac157.pj@sgi.com>
	<20060629110107.2e56310b.akpm@osdl.org>
	<44A57310.3010208@watson.ibm.com>
	<44A5770F.3080206@watson.ibm.com>
	<20060630155030.5ea1faba.akpm@osdl.org>
	<44A5DBE7.2020704@watson.ibm.com>
	<44A5EDE6.3010605@watson.ibm.com>
	<20060630205148.4f66b125.akpm@osdl.org>
	<44A9881F.7030103@watson.ibm.com>
	<20060703144106.cc5bd6f6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nagar@watson.ibm.com, Valdis.Kletnieks@vt.edu, jlan@engr.sgi.com,
	balbir@in.ibm.com, csturtiv@sgi.com, linux-kernel@vger.kernel.org,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:58021 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S932381AbWGDUTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 16:19:41 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060703144106.cc5bd6f6.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew wrote:
> OK, so we're passing in an ASCII string.  Fair enough, I think.  Paul would
> know better.

Not sure if I know better - just got stronger opinions.

I like the ASCII here - but this is one of those "he who
writes the code gets to 

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
