From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 0/2] Labeled networking patches for 2.6.26
Date: Thu, 10 Apr 2008 15:47:20 -0700 (PDT)
Message-ID: <20080410.154720.05259434.davem@davemloft.net>
References: <200804101725.59604.paul.moore@hp.com>
	<Xine.LNX.4.64.0804110802140.1313@us.intercode.com.au>
	<200804101812.36542.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757425AbYDJWrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 18:47:19 -0400
In-Reply-To: <200804101812.36542.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 10 Apr 2008 18:12:36 -0400

> On Thursday 10 April 2008 6:04:32 pm James Morris wrote:
> > On Thu, 10 Apr 2008, Paul Moore wrote:
> > > Just a quick follow-up on testing, I've run this for a few hours on
> > > two Fedora systems with both labeled and unlabeled IPsec in use
> > > with SAs rekeying every 5 minutes and didn't notice anything evil.
> > >
> > > At this point I'd strip the "RFC" from the patchset and ask that
> > > they be considered for inclusion in 2.6.26 assuming there are no
> > > objections.
> >
> > I suggest pushing them via DaveM's tree, unless they depend on
> > anything in my tree.
> 
> Okay.  It sounds like DaveM is working through a backlog right now, if I 
> don't see them in his tree by next week I'll resubmit them.

I'll pull this stuff in at the next opportunity.

Thanks guys.
