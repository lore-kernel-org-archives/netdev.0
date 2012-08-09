From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Per-net and on-demand link indices (and
 related) v3
Date: Thu, 09 Aug 2012 16:18:24 -0700 (PDT)
Message-ID: <20120809.161824.1716156583320758605.davem@davemloft.net>
References: <50236C20.4050108@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2HIXSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 19:18:25 -0400
In-Reply-To: <50236C20.4050108@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 09 Aug 2012 11:52:00 +0400

> This set tries to summarize the recent discussion of making ifindices friendly
> to checkpoint-restore and consists of:
> 
> 1. Prepare hash function to non-unique ifindices
> 2. Allow for specifying the desired ifindex on net link creation
> 3. Make ifindex generation per-net
> 4. Simplify loopback device ifindex access

Looks good, all applied to net-next, thanks.
