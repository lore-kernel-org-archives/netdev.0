From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 1/4] pfkey: sending an SADB_GET responds with an SADB_GET
Date: Thu, 22 Nov 2007 19:35:43 +0800
Message-ID: <20071122113543.GA9020@gondor.apana.org.au>
References: <200711212302.lALN2DYa013601@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, chardin@2wire.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4320 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751958AbXKVLf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:35:56 -0500
Content-Disposition: inline
In-Reply-To: <200711212302.lALN2DYa013601@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 11:02:13PM +0000, akpm@linux-foundation.org wrote:
> From: Charles Hardin <chardin@2wire.com>
> 
> Kernel needs to respond to an SADB_GET with the same message type to
> conform to the RFC 2367 Section 3.1.5
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.  Thanks Andrew.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
