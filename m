From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] virtio: Net header needs gso_hdr_len
Date: Wed, 23 Jan 2008 09:29:11 +1100
Message-ID: <20080122222911.GA29737@gondor.apana.org.au>
References: <E1JEvnR-0006ax-00@gondolin.me.apana.org.au> <200801161519.03339.rusty@rustcorp.com.au> <20080122103630.GA24135@gondor.apana.org.au> <200801230906.14585.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50756 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752651AbYAVW3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 17:29:16 -0500
Content-Disposition: inline
In-Reply-To: <200801230906.14585.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2008 at 09:06:14AM +1100, Rusty Russell wrote:
>
> > So this field is fine with me as long as it is named as such to
> > avoid confusion since it really has nothing to do with GSO as you
> > also need it for SG with large MTUs.
> 
> Hmm, how about just "hdr_len" rather than "gso_hdr_len"?

Sounds fine to me.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
