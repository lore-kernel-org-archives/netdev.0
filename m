From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC 0/3] Add AEAD support to ESP
Date: Tue, 11 Dec 2007 12:23:12 +0800
Message-ID: <20071211042312.GA10911@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2260 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752076AbXLKEXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 23:23:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This series of patches add AEAD support to ESP.

Please don't merge it just yet because they depend on what's
in the current cryptodev-2.6 tree.  Once that tree has settled
down I'll ask you to pull it and then these patches can go on
top of that.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
