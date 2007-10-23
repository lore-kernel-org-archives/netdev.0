From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/11] Merge bundle creation and other misc fixes/clean-ups
Date: Wed, 24 Oct 2007 00:02:17 +0800
Message-ID: <20071023160217.GA32102@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2422 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751960AbXJWQCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 12:02:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This series of patches fixes the bug where the bundle creation
code treats IPv6 routes as IPv4 or vice versa.

I think this is suitable for 2.6.25.

They do fix bugs but I don't think any of them are serious enough
for inclusion in 2.6.24.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
