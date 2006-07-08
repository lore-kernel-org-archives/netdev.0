From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: airo maybe should select crypto_aes
Date: Sat, 08 Jul 2006 14:37:41 +1000
Message-ID: <E1Fz4ZZ-0001V1-00@gondolin.me.apana.org.au>
References: <44AC269B.6000704@net-pr.de>
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27148 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932510AbWGHEhy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 00:37:54 -0400
To: rob@net-pr.de (Robert Schulze)
In-Reply-To: <44AC269B.6000704@net-pr.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Schulze <rob@net-pr.de> wrote:
> 
> I first wrote to the linux-pcmcia ML, but they said it wasn't the right 
> address for my issue. The driver airo (for Cisco Wlan-Cards) complains 
> about "failed to load transform for AES", when it is loaded and 
> CRYPTO_AES is not selected in Kconfig.
> I've got a patch for that, maybe it's worth it.

First of your patch is space-damaged.  Please make sure that the
original tabs are preserved and resend.

Also, wireless patches should be sent to this list with a cc to
John W. Linville <linville@tuxdriver.com>.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
