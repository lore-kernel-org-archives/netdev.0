From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bridge] bridging with gre tunnel
Date: Mon, 14 Jul 2008 20:20:08 +0800
Message-ID: <20080714122008.GA28651@gondor.apana.org.au>
References: <E1KIMV2-0007Na-00@gondolin.me.apana.org.au> <487B4352.6040408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Craig <philipc@snapgear.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, timo.teras@iki.fi
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49306 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751470AbYGNMUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 08:20:15 -0400
Content-Disposition: inline
In-Reply-To: <487B4352.6040408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 02:15:14PM +0200, Patrick McHardy wrote:
>
> Or use rtnl_link, which was created for this purpose :)

Excellent, now there is even less excuse to bother with the ioctls :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
