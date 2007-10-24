From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] [IPSEC]: Separate inner/outer family processing on output
Date: Wed, 24 Oct 2007 22:58:50 +0800
Message-ID: <20071024145850.GA10589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Joakim Koskela <joakim.koskela@hiit.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1878 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752118AbXJXPAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 11:00:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

These three patches are the first step in fixing inter-family
support on the data path (the previous series should've solved
it for the control path).

I still need to fix the continuation on the output path and
repeat this process for the input path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
