From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Thu, 29 Jan 2009 11:34:29 +1100
Message-ID: <20090129003429.GA23582@gondor.apana.org.au>
References: <20090116211312.22836.34331.stgit@debian.lart> <200901282115.14083.rusty@rustcorp.com.au> <1233164908.7026.195.camel@lappy> <200901291025.46887.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Williamson <alex.williamson@hp.com>, netdev@vger.kernel.org,
	markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56743 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764284AbZA2Aej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 19:34:39 -0500
Content-Disposition: inline
In-Reply-To: <200901291025.46887.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2009 at 10:25:46AM +1030, Rusty Russell wrote:
>
> So, this conversation has convinced me that the host should
> accept arbitrary filtering entries, and the guest should accept
> that it is best effort.

I agree with this completely.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
