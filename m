From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP send/ack lockstep problem
Date: Sat, 02 Sep 2006 12:46:34 +1000
Message-ID: <E1GJLWk-0006P6-00@gondolin.me.apana.org.au>
References: <eda9s9$bgq$1@sea.gmane.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44295 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750715AbWIBCql
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 22:46:41 -0400
To: matthias@urlichs.de (Matthias Urlichs)
In-Reply-To: <eda9s9$bgq$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthias Urlichs <matthias@urlichs.de> wrote:
> 
> Any ideas? Is the sending program doing something stupid? If so, what?

Probably.  Since you're on the sender's side (192.109.x.x I presume) why
don't you do a strace on the sending process and tell us?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
VGER BF report: U 0.500002
