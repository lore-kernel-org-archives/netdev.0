From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.43 0/5] MPLS actions and matches
Date: Wed, 16 Oct 2013 13:23:59 +0900
Message-ID: <20131016042359.GA22553@verge.net.au>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
 <20131010003139.GA20311@verge.net.au>
 <20131016035530.GA29165@nicira.com>
 <20131016035600.GB29165@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48861 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab3JPEYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 00:24:03 -0400
Content-Disposition: inline
In-Reply-To: <20131016035600.GB29165@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 08:56:00PM -0700, Ben Pfaff wrote:
> On Tue, Oct 15, 2013 at 08:55:30PM -0700, Ben Pfaff wrote:
> > On Thu, Oct 10, 2013 at 09:31:41AM +0900, Simon Horman wrote:
> > > I believe this series addresses the feedback that each of you
> > > gave with regards to recent previous postings of this patch-set.
> > > I'm wondering if you could find some time to review it.
> > 
> > I'm waiting for an ack from Jesse, then I'm going to do a final pass and
> > I hope to commit this series at this point.  I see some ways that we can
> > improve MPLS support afterward but I don't see any blockers.
> 
> (Yet.  Somehow MPLS seems to require fractal review.)

If you notice something please let me know :)
