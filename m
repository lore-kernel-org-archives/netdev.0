From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-03-12
Date: Wed, 13 Mar 2013 05:17:03 -0400 (EDT)
Message-ID: <20130313.051703.503945145726981351.davem@davemloft.net>
References: <1363110445.2780.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	scrum-linux@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474Ab3CMJQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 05:16:52 -0400
In-Reply-To: <1363110445.2780.14.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 12 Mar 2013 17:47:25 +0000

> The following changes since commit c80a8512ee3a8e1f7c3704140ea55f21dc6bd651:
> 
>   net/core: move vlan_depth out of while loop in skb_network_protocol() (2013-03-12 11:47:40 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9
> 
> (commit fae8563b25f73dc584a07bcda7a82750ff4f7672)
> 
> Just the one bug fix I mentioned before, but it's a pretty important one
> as it can cause silent data corruption or IOMMU page faults.
> 
> This would be suitable for stable and should apply cleanly to all the
> 3.x.y branches.  I'm still working through testing of larger sets of
> fixes.

Pulled, thanks Ben.
