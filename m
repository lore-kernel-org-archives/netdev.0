From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH Round 3 0/2][RFC] Network Event Notifier Mechanism
Date: Wed, 28 Jun 2006 13:04:00 +1000
Message-ID: <20060628030400.GA4474@gondor.apana.org.au>
References: <20060627205050.30723.25753.stgit@stevo-desktop> <E1FvQBu-00018u-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63497 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422930AbWF1DEP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:04:15 -0400
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <E1FvQBu-00018u-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 12:54:10PM +1000, Herbert Xu wrote:
> 
> Please give more specific reasons for needing these events because it
> is certainly far from obvious from reading those documents.

Never mind, I've found your earlier messages on the list which explains
your reasons more clearly.  It would be nice if you could include those
explanations in your patch description.

BTW, does this mean that we're now comfortable with full TOE?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
