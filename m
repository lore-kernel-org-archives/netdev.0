From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V3,repost 0/4] net: allow to change carrier
 from userspace
Date: Fri, 28 Dec 2012 15:21:21 -0800 (PST)
Message-ID: <20121228.152121.1771069747366138602.davem@davemloft.net>
References: <1356688180-3549-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab2L1XVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 18:21:24 -0500
In-Reply-To: <1356688180-3549-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 28 Dec 2012 10:49:36 +0100

> This is basically a V3 of a repost of my previous patchset:
> "[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30
> 
> The way net-sysfs stores values changed and this patchset reflects it.
> Also, I exposed carrier via rtnetlink iface.
> 
> So far, only dummy driver uses carrier change ndo. In very near future
> team driver will use that as well.

Series applied, thanks.
