From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH] net/core/sock.c remove extra wakeup)
Date: Fri, 13 Jun 2008 00:05:54 +1000
Message-ID: <20080612140554.GA3846@gondor.apana.org.au>
References: <483F990C0200005A00038001@sinclair.provo.novell.com> <E1K6K60-00061s-00@gondolin.me.apana.org.au> <20080611.021642.217166694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: GHaskins@novell.com, PMullaney@novell.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52327 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760146AbYFLOGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 10:06:04 -0400
Content-Disposition: inline
In-Reply-To: <20080611.021642.217166694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2008 at 02:16:42AM -0700, David Miller wrote:
> 
> Deletion of sk->sk_callback_lock.

Looks pretty reasonable.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
