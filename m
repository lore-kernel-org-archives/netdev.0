From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPROUTE]: Bogus changeset on ALGO_NAME/ALGO_KEY
Date: Wed, 5 Mar 2008 19:46:43 +0800
Message-ID: <20080305114643.GA27967@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38713 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755478AbYCELqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 06:46:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen:

The changeset 8a1485bb21bf84a7932ca849e29300853e647afc is completely
bogus as you can't add an SA without specifying the algorithm name
or the key.

So please revert it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
