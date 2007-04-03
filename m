From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] TCP Illinois preliminary version
Date: Mon, 2 Apr 2007 20:44:58 -0700
Message-ID: <20070402204458.5aa6c0c7@oldman>
References: <20070312164311.13b5fcec@freekitty>
	<200703142247.l2EMln1o000338@expredir5.cites.uiuc.edu>
	<20070402201525.3d18a080@localhost.localdomain>
	<20070402.203937.59657200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shaoliu@uiuc.edu, chaitanya_tk@tamu.edu, jgarrison@tamu.edu,
	srikant@ifp.uiuc.edu, tbasar@control.csl.uiuc.edu,
	jheffner@psc.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59439 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbXDCDpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 23:45:53 -0400
In-Reply-To: <20070402.203937.59657200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 02 Apr 2007 20:39:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 2 Apr 2007 20:15:25 -0700
> 
> > Preliminary version if TCP Illinois for 2.6.22.
> > It needs more testing and refinement but it captures the
> > basic concepts.
> 
> No objections from me and I don't see any obvious problems.
> 
> Would you like me to stuff this into net-2.6.22 now so that
> it can get some more exposure and people banging on it or
> would you like me to wait a bit?
> 
> Thanks.

I would like one of the originators to check the math. 

In case you are worried, I received assurance from Shao Liu that they decided
not to pursue patent and doing a Linux version was okay.
