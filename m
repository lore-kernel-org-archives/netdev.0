From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH] bnx2x: Update to FW version 7.12.30
Date: Tue, 14 Jul 2015 17:04:49 -0400
Message-ID: <20150714210449.GV13281@merlin.infradead.org>
References: <1434866091-30087-1-git-send-email-Yuval.Mintz@qlogic.com>
 <B5657A6538887040AD3A81F1008BEC63DD93BB@avmb3.qlogic.org>
 <B5657A6538887040AD3A81F1008BEC63DE5037@avmb3.qlogic.org>
 <B5657A6538887040AD3A81F1008BEC63DE54D0@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:56567 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbGNVEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 17:04:53 -0400
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63DE54D0@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 10:17:24AM +0000, Yuval Mintz wrote:
> > > > The new FW will allow us to utilize some new features in our driver,
> > > > mainly adding vlan filtering offload and vxlan offload support.
> > > >
> > > > In addition, this fixes several issues:
> > > > 1. Packets from a VF with pvid configured which were sent with a
> > > >    different vlan were transmitted instead of being discarded.
> > > >
> > > > 2. FCoE traffic might not recover after a failue while there's traffic
> > > >    to another function.
> > > >
> > > > Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > >
> > > Hi, any news about this one?
> > > Thanks, Yuval
> > 
> > Any updates? I've sent this 3-weeks ago and haven't seen any reply.
> 
> Apparently the destination E-mail has changed and I was unaware.
> Is anyone here? ;-)
> 

Hmm?

--Kyle
