From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] make sunrpc/xprtsock.c:xs_setup_{udp,tcp}() static
Date: Thu, 22 Nov 2007 19:38:33 +0800
Message-ID: <20071122113833.GB9020@gondor.apana.org.au>
References: <200711212302.lALN2Eoj013604@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, bunk@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4402 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751044AbXKVLik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:38:40 -0500
Content-Disposition: inline
In-Reply-To: <200711212302.lALN2Eoj013604@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 11:02:14PM +0000, akpm@linux-foundation.org wrote:
> From: Adrian Bunk <bunk@kernel.org>
> 
> xs_setup_{udp,tcp}() can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
