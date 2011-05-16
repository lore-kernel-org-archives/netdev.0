From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 22:18:57 +1000
Message-ID: <20110516121857.GA4495@gondor.apana.org.au>
References: <20110505084428.GB17647@redhat.com> <4DC26F33.8010700@cn.fujitsu.com> <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com> <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com> <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com> <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34525 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab1EPMTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 08:19:06 -0400
Content-Disposition: inline
In-Reply-To: <20110516112133.GA11274@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 02:21:33PM +0300, Michael S. Tsirkin wrote:
>
> Yes, but then we get annoying info messages every time.
> Change them all to debug or remove completely?

If you are getting warning messages then it probably means that
your driver is doing something wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
