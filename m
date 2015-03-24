From: David Miller <davem@davemloft.net>
Subject: Re: [v3 PATCH 0/9] rhashtable: Multiple rehashing
Date: Mon, 23 Mar 2015 22:09:13 -0400 (EDT)
Message-ID: <20150323.220913.317244497700484970.davem@davemloft.net>
References: <20150323134955.GA16328@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbCXCJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:09:15 -0400
In-Reply-To: <20150323134955.GA16328@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Mar 2015 00:49:55 +1100

> This series introduces multiple rehashing.

This looks great, nice work.  All applied to net-next.

Could you please add a comment next to the "16" from patch
#9 explaining why that value was choosen and the invariants
that influence it?

Thanks!
