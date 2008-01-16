From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: questions on NAPI processing latency and dropped network	packets
Date: Wed, 16 Jan 2008 11:17:08 +1100
Message-ID: <E1JEvxs-0006cZ-00@gondolin.me.apana.org.au>
References: <20080115202905.GA2680@ami.dom.local>
Cc: cfriesen@nortel.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jarkao2@gmail.com (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55592 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751440AbYAPARQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 19:17:16 -0500
In-Reply-To: <20080115202905.GA2680@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
>
> So, it was more a rhetorical trick (sorry!) to suggest, that such a
> business model of being always late with kernels might be quite
> practical and reasonable for many companies, but looks like the
> worst possible development model for Linux.

Well people are always going to operate on this model for commercial
reasons.  FWIW I used to work for a company that stuck to a specific
version of the Linux kernel, and I suppose I still do even now :)

But the important thing is that if you're going to do that, then the
cost that comes with it should be borne by the company and not the
community.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
