From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix macvlan_get_size()
Date: Thu, 17 Jan 2013 16:41:09 -0500 (EST)
Message-ID: <20130117.164109.1298335351314830982.davem@davemloft.net>
References: <1358316108.19956.82.camel@edumazet-glaptop>
	<20130116.011120.2166745757980086775.davem@davemloft.net>
	<1358458249.11051.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033Ab3AQVlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 16:41:12 -0500
In-Reply-To: <1358458249.11051.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Jan 2013 13:30:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit df8ef8f3aaa (macvlan: add FDB bridge ops and macvlan flags)
> forgot to update macvlan_get_size() after the addition of
> IFLA_MACVLAN_FLAGS
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks Eric.
