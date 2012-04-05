From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Do not send queries on multicast group leaves
Date: Thu, 5 Apr 2012 08:58:06 +0800
Message-ID: <20120405005805.GA17810@gondor.apana.org.au>
References: <20120404110119.GA11576@gondor.apana.org.au> <CAA93jw658iHuuYWSz7QrV3ZHOvn1gL7DxAtFfQ0gos6jZjTKiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:45596 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757211Ab2DEA6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:58:11 -0400
Content-Disposition: inline
In-Reply-To: <CAA93jw658iHuuYWSz7QrV3ZHOvn1gL7DxAtFfQ0gos6jZjTKiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 04, 2012 at 08:52:52AM -0700, Dave Taht wrote:
> 
> 1) Has anyone seen linux working as a multicast router of late? because I
> sure haven't.

Linux works as a multicast router.  The functionality is in
user-space and has nothing to do with this whatsoever.
 
> 2) Does this bridge code change break existing applications of IGMP over a
> lonely bridge?

No.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
