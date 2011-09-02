From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
 ethtool application.
Date: Fri, 02 Sep 2011 22:23:19 +0100
Message-ID: <1314998599.3419.8.camel@bwh-desktop>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
	 <20110902.165524.1076389492712310664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28509 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927Ab1IBVXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:23:22 -0400
In-Reply-To: <20110902.165524.1076389492712310664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 16:55 -0400, David Miller wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Date: Fri,  2 Sep 2011 13:50:30 -0700
> 
> > This patch completes the user space implementation of the private
> > flags inteface in ethtool. Using -b/-B options.
> > 
> > Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> The only use case you show here is something generic which other
> chips have, Energy Efficient Ethernet.
> 
> Making an attribute private which is present widely amonst various
> networking chips makes no sense at all.
> 
> It deserved a generic ethtool flag.

I agree.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
