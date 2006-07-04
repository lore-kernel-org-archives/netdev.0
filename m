From: Horms <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Add sysctl documentation
Date: Tue, 4 Jul 2006 15:10:26 +0900
Message-ID: <20060704061025.GB11599@verge.net.au>
References: <20060630061940.GA31956@verge.net.au> <20060630.142045.106433722.davem@davemloft.net> <20060703023128.GA27424@verge.net.au> <20060703.193647.08322498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41925 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751250AbWGDGYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 02:24:47 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060703.193647.08322498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2006 at 07:36:47PM -0700, David Miller wrote:
> From: Horms <horms@verge.net.au>
> Date: Mon, 3 Jul 2006 11:31:30 +0900
> 
> > * Derived from http://www.linuxvirtualserver.org/docs/sysctl.html, v1.4
> >   maintained by Wensong Zhang
> > 
> > * Adjusted preample to match ip-sysctl.txt
> > 
> > * Sorted options into alphabetical order
> > 
> > * Added expire_quiescent_template
> > 
> > * Removed timeout_* which are no longer present
> > 
> > * Incoporated doc/debug-levels.txt from IPVS source tree into
> >   description of ipvs_debug
> > 
> > * Minor spelling fixes
> > 
> > * Further editing more than welcome
> > 
> > Signed-Off-By: Horms <horms@verge.net.au>
> 
> Applied, thanks Simon.
> 
> > * DaveM, do you need a 2.4 version of this document,
> >   it will likely be a slightly different list of options?
> 
> I don't think it's really worthwhile, we should be touching 2.4.x
> as little as possible at this point.  Changes we make in 2.4.x
> should be in the "absolutely necssary" category.

Understood, I'm more than happy to let that sleeping dog lie.

-- 
Horms                                           
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

