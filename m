From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [IPV6]: Replace sk_buff ** with sk_buff * in input
 handlers
Date: Mon, 15 Oct 2007 01:29:39 -0700 (PDT)
Message-ID: <20071015.012939.36941069.davem@davemloft.net>
References: <20071014144649.GA14792@gondor.apana.org.au>
	<E1Ih4m9-0003s7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754994AbXJOI3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:29:35 -0400
In-Reply-To: <E1Ih4m9-0003s7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Oct 2007 22:49:05 +0800

> [IPV6]: Replace sk_buff ** with sk_buff * in input handlers
> 
> With all the users of the double pointers removed from the IPv6 input path,
> this patch converts all occurances of sk_buff ** to sk_buff * in IPv6 input
> handlers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
