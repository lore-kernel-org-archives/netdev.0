From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 21:11:08 +1000
Message-ID: <20080819111107.GA30250@gondor.apana.org.au>
References: <20080819.035406.107673885.davem@davemloft.net> <20080819105551.GA30114@gondor.apana.org.au> <20080819105815.GA30148@gondor.apana.org.au> <20080819.040200.155911269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51531 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751039AbYHSL01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 07:26:27 -0400
Content-Disposition: inline
In-Reply-To: <20080819.040200.155911269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 04:02:00AM -0700, David Miller wrote:
> 
> I just checked the following into net-2.6

Thanks Dave!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
