From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] [IPSEC]: Reinject packet instead of calling netfilter directly on input
Date: Mon, 3 Dec 2007 20:21:44 +1100
Message-ID: <20071203092144.GB22869@gondor.apana.org.au>
References: <1196369374.4437.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3528 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751464AbXLCJV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 04:21:57 -0500
Content-Disposition: inline
In-Reply-To: <1196369374.4437.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 29, 2007 at 03:49:34PM -0500, jamal wrote:
> Herbert,
> 
> This is a simplified version of one of your earlier patches that never
> made it in. I liked it so much that i reduced it to this and infact
> given the cycles today, tested it (with transport and tunnel mode
> only;->).

Sorry for the late response Jamal.  I've been too busy to give
this issue proper thought.  It's still in my mailbox so I will
respond to it once things quiten down a little.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
