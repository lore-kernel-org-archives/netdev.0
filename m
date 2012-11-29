From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 5/9] net: frag, per CPU resource, mem limit
 and LRU list accounting
Date: Thu, 29 Nov 2012 12:31:26 -0500 (EST)
Message-ID: <20121129.123126.1852507751101669688.davem@davemloft.net>
References: <20121129161019.17754.29670.stgit@dragon>
	<20121129161303.17754.47046.stgit@dragon>
	<1354208776.14302.1898.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab2K2Rbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:31:31 -0500
In-Reply-To: <1354208776.14302.1898.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Nov 2012 09:06:16 -0800

> Not counting the addition of a NR_CPUS array, which is really
> unfortunate these days.

That is addressed in patch #6.
