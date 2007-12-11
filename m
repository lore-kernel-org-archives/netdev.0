From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/2] [IPSEC]: Add host ICMP relookup support
Date: Wed, 12 Dec 2007 00:53:17 +0800
Message-ID: <20071211165317.GA16420@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2017 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751561AbXLKQxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 11:53:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

These two patches implement the ICMP relookup feature for hosts
that's required by RFC 4301.  I've made it conditional on policy
and state flags so it should have no impact on existing users.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
