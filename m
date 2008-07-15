From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/5] virtio net: Add ethtool ops for SG/GSO
Date: Tue, 15 Jul 2008 11:49:19 +0800
Message-ID: <20080715034919.GA2657@gondor.apana.org.au>
References: <200807151340.49604.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53367 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754044AbYGODtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:49:35 -0400
Content-Disposition: inline
In-Reply-To: <200807151340.49604.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 10:40:49PM -0500, Rusty Russell wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> 
> This patch adds some basic ethtool operations to virtio_net so
> I could test SG without GSO (which was really useful because TSO
> turned out to be buggy :)
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (remove MTU setting)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
