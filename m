From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 09:00:21 +1000
Message-ID: <E1Fb3qv-0005Vp-00@gondolin.me.apana.org.au>
References: <44578691.4020402@corky.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2571 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965033AbWEBXAY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 19:00:24 -0400
To: marc@corky.net (Just Marc)
In-Reply-To: <44578691.4020402@corky.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just Marc <marc@corky.net> wrote:
> 
> Looking at mailing list archives there has been much talk of this print 
> in the past, given the fact that this check/print is surrounded by an 

A good number of these turned out to be a bug in the Linux TCP stack.
If this message wasn't there we would've never found it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
