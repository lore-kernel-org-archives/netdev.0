From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.43 0/5] MPLS actions and matches
Date: Tue, 15 Oct 2013 20:56:00 -0700
Message-ID: <20131016035600.GB29165@nicira.com>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
 <20131010003139.GA20311@verge.net.au>
 <20131016035530.GA29165@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:57053 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757547Ab3JPD4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 23:56:06 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so428876pab.13
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 20:56:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131016035530.GA29165@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 08:55:30PM -0700, Ben Pfaff wrote:
> On Thu, Oct 10, 2013 at 09:31:41AM +0900, Simon Horman wrote:
> > I believe this series addresses the feedback that each of you
> > gave with regards to recent previous postings of this patch-set.
> > I'm wondering if you could find some time to review it.
> 
> I'm waiting for an ack from Jesse, then I'm going to do a final pass and
> I hope to commit this series at this point.  I see some ways that we can
> improve MPLS support afterward but I don't see any blockers.

(Yet.  Somehow MPLS seems to require fractal review.)
