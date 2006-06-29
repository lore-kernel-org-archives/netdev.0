From: Paul Jackson <pj@sgi.com>
Subject: Re: [Patch][RFC] Disabling per-tgid stats on task exit in taskstats
Date: Thu, 29 Jun 2006 14:22:27 -0700
Message-ID: <20060629142227.bca8143b.pj@sgi.com>
References: <44892610.6040001@watson.ibm.com>
	<44999F5A.2080809@watson.ibm.com>
	<4499D7CD.1020303@engr.sgi.com>
	<449C2181.6000007@watson.ibm.com>
	<20060623141926.b28a5fc0.akpm@osdl.org>
	<449C6620.1020203@engr.sgi.com>
	<20060623164743.c894c314.akpm@osdl.org>
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
	<44A425A7.2060900@watson.ibm.com>
	<20060629123338.0d355297.akpm@osdl.org>
	<44A43187.3090307@watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Valdis.Kletnieks@vt.edu, jlan@engr.sgi.com,
	balbir@in.ibm.com, csturtiv@sgi.com, linux-kernel@vger.kernel.org,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:30379 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S932716AbWF2VWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:22:55 -0400
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <44A43187.3090307@watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shailabh wrote:
>  How much memory do these 1024 CPU machines have 

From:

    http://www.hpcwire.com/hpc/653963.html (May 12, 2006)

    SGI has already shipped more than a dozen SGI systems with
    over a terabyte of memory and about a hundred systems of half
    a terabyte or larger. But the new Altix will have much larger
    memory capacities. The systems SGI has in mind will scale to tens
    of terabytes and beyond. In fact, a few SGI customers are already
    testing with systems in the 10-terabyte range. "The largest we
    have shipped is a 13-terabyte memory system for the Japan Atomic
    Energy Agency," said [SGI CTO Dr. Eng Lim] Goh.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
