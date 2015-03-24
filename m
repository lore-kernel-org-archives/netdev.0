From: David Miller <davem@davemloft.net>
Subject: Re: [v3 PATCH 0/9] rhashtable: Multiple rehashing
Date: Tue, 24 Mar 2015 14:57:30 -0400 (EDT)
Message-ID: <20150324.145730.591778015335401246.davem@davemloft.net>
References: <20150323134955.GA16328@gondor.apana.org.au>
	<20150323.220913.317244497700484970.davem@davemloft.net>
	<20150324023729.GA7973@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbCXS5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:57:33 -0400
In-Reply-To: <20150324023729.GA7973@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Mar 2015 13:37:30 +1100

> rhashtable: Add comment on choice of elasticity value
> 
> This patch adds a comment on the choice of the value 16 as the
> maximum chain length before we force a rehash.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for following up on this, applied.
