From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH v2 -mm 1/9] netconsole: Cleanups, codingstyle, prettyfication
Date: Tue, 10 Jul 2007 04:02:45 -0500
Message-ID: <20070710090245.GJ11115@waste.org>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091925.23907.3312.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:54948 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244AbXGJJDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 05:03:55 -0400
Content-Disposition: inline
In-Reply-To: <20070710091925.23907.3312.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 02:49:25PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [1/9] netconsole: Cleanups, codingstyle, prettyfication
> 
> (1) Remove unwanted headers.
> (2) Mark __init and __exit as appropriate.
> (3) Various trivial codingstyle and prettification stuff.

I don't much like what you've done in (3) because I personally think
tabs should never appear anywhere but at the beginning of a line.
Which is why we consistently ask for people not to mix codingstyle
bits with substantive changes.

But what the hell..

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.
