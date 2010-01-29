From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Fri, 29 Jan 2010 12:17:49 +0530
Message-ID: <20100129064747.GA11514@serverengines.com>
References: <20100128232829.GA31884@kroah.com>
 <1264722956.373.561.camel@localhost>
 <20100129055157.GA10427@serverengines.com>
 <20100128.215629.189699027.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ajitkhaparde@gmail.com, ben@decadent.org.uk, greg@kroah.com,
	netdev@vger.kernel.org, stable-review@kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:35460 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751811Ab0A2Gri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 01:47:38 -0500
Content-Disposition: inline
In-Reply-To: <20100128.215629.189699027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/01/10 21:56 -0800, David Miller wrote:
> From: Ajit Khaparde <ajitkhaparde@gmail.com>
> Date: Fri, 29 Jan 2010 11:21:59 +0530
> 
> > I plan rectify the error pointed by Ben and Greg and spin the patch again and
> > resend it.  Please let me know if you think otherwise.
> 
> I already made the obvious memset() arg fix in my tree
> as I said I would in my reply to Ben's posting.
I never saw this mail. Probably its lost for good.
It did not even show up on
http://patchwork.ozlabs.org/patch/43852

Thanks
> 
> It never makes sense to 'respin' patches I've already
> applied to net-2.6, once I push it out to kernel.org
> it's irreversable so you must send relative fixes.
