From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 4/4] Net: sunrpc, remove SPIN_LOCK_UNLOCKED
Date: Thu, 22 Nov 2007 19:40:37 +0800
Message-ID: <20071122114037.GC9020@gondor.apana.org.au>
References: <200711212302.lALN2G3A013610@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jirislaby@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4493 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751240AbXKVLko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:40:44 -0500
Content-Disposition: inline
In-Reply-To: <200711212302.lALN2G3A013610@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 11:02:15PM +0000, akpm@linux-foundation.org wrote:
> From: Jiri Slaby <jirislaby@gmail.com>
> 
> sunrpc, remove SPIN_LOCK_UNLOCKED
> 
> SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
