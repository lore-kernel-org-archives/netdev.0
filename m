From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [git patches] net driver fixes
Date: Tue, 02 Jan 2007 13:23:51 +1100
Message-ID: <E1H1ZJf-0002cA-00@gondolin.me.apana.org.au>
References: <20061226224646.GA10417@havoc.gtf.org>
Cc: akpm@osdl.org, torvalds@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1622 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754370AbXABCYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 21:24:07 -0500
To: jeff@garzik.org (Jeff Garzik)
In-Reply-To: <20061226224646.GA10417@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
> 
>      e1000: Do not truncate TSO TCP header with 82544 workaround

This change obsoletes the following change.

>      e1000: disable TSO on the 82544 with slab debugging

So the slab debugging patch should be reverted.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
