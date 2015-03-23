From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 12:45:33 -0400 (EDT)
Message-ID: <20150323.124533.1126839778429111512.davem@davemloft.net>
References: <20150323000954.GB9507@gondor.apana.org.au>
	<20150323083319.GB16023@casper.infradead.org>
	<20150323092806.GA12506@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbCWQpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 12:45:35 -0400
In-Reply-To: <20150323092806.GA12506@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 Mar 2015 20:28:07 +1100

> You never want automatic shrinking unless all your users are
> trusted.

+1
