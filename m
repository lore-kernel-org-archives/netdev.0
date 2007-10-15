From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [IPV6]: Replace sk_buff ** with sk_buff * in input handlers
Date: Mon, 15 Oct 2007 22:21:14 +0800
Message-ID: <20071015142114.GA32611@gondor.apana.org.au>
References: <20071014144649.GA14792@gondor.apana.org.au> <E1Ih4m9-0003s7-00@gondolin.me.apana.org.au> <20071015.012939.36941069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2019 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753415AbXJOOWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 10:22:02 -0400
Content-Disposition: inline
In-Reply-To: <20071015.012939.36941069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 01:29:39AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 14 Oct 2007 22:49:05 +0800
> 
> > [IPV6]: Replace sk_buff ** with sk_buff * in input handlers
> > 
> > With all the users of the double pointers removed from the IPv6 input path,
> > this patch converts all occurances of sk_buff ** to sk_buff * in IPv6 input
> > handlers.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Also applied, thanks Herbert.

I just pulled your tree and this patch seems to be missing.
Everything else seems to be there though.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
