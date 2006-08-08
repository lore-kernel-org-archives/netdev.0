From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tg3: Fix tx race condition
Date: Tue, 8 Aug 2006 14:23:36 +1000
Message-ID: <20060808042336.GA14039@gondor.apana.org.au>
References: <1155006336.5328.24.camel@rh4> <20060807.200556.40833596.davem@davemloft.net> <1155010214.5328.27.camel@rh4> <20060807.212135.77057626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32268 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932480AbWHHEXn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:23:43 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060807.212135.77057626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 09:21:35PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Mon, 07 Aug 2006 21:10:14 -0700
> 
> > Fix a subtle race condition between tg3_start_xmit() and tg3_tx()
> > discovered by Herbert Xu <herbert@gondor.apana.org.au>:
> 
> This one looks good to me.  Herbert please ACK this if you agree.

Yes the patch looks good to me too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
