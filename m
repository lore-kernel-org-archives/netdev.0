From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/16]: Kill the ipv4 routing cache.
Date: Fri, 20 Jul 2012 18:22:28 +0100
Message-ID: <1342804948.2678.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120719.143403.1702333347618917729.davem@davemloft.net>
	 <1342796969.2678.12.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120720.092614.1285553995467252576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51493 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752498Ab2GTRWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 13:22:31 -0400
In-Reply-To: <20120720.092614.1285553995467252576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 09:26 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 20 Jul 2012 16:09:29 +0100
> 
> > On Thu, 2012-07-19 at 14:34 -0700, David Miller wrote:
> >> The ipv4 routing cache is non-deterministic, performance wise, and is
> >> subject to reasonably easy to launch denial of service attacks.
> > [...]
> > 
> > This is a great explanation, but it still doesn't appear to be going
> > into the commit log...
> 
> What in the world do you mean?
> 
> When I actually commit this stuff, I'll have it all in a branch and
> merge it into net-next's master using "git merge --no-ff" and then use
> the merge commit to add this commit message test.
> 
> Every damn set of changes I've commited over the past few weeks have
> used this technique, are you simply not paying attention?

Sorry, I get it now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
