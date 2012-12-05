From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] bridge: implement multicast fast leave
Date: Wed, 05 Dec 2012 16:25:33 -0500 (EST)
Message-ID: <20121205.162533.472441435180068286.davem@davemloft.net>
References: <20121204084431.72f9084c@nehalam.linuxnetplumber.net>
	<1354691991-18499-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.hengli.com.au, shemminger@vyatta.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab2LEVZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:25:35 -0500
In-Reply-To: <1354691991-18499-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  5 Dec 2012 15:19:51 +0800

> V3: make it a flag
> V2: make the toggle per-port
> 
> Fast leave allows bridge to immediately stops the multicast
> traffic on the port receives IGMP Leave when IGMP snooping is enabled,
> no timeouts are observed.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
