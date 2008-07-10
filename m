From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 10 Jul 2008 07:27:38 +0200
Message-ID: <20080710052738.GU9549@secunet.com>
References: <20080705071950.GA26532@secunet.com> <20080705115654.GA18290@gondor.apana.org.au> <20080708095335.GP9549@secunet.com> <20080708104022.GA26280@gondor.apana.org.au> <20080709142418.GT9549@secunet.com> <20080710011248.GA20626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:55189 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbYGJF1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 01:27:41 -0400
Content-Disposition: inline
In-Reply-To: <20080710011248.GA20626@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 09:12:48AM +0800, Herbert Xu wrote:
> On Wed, Jul 09, 2008 at 04:24:18PM +0200, Steffen Klassert wrote:
> >
> > Just to get you right, do you mean something like the patch below?
> > With this and a patched iproute2 I've got the inter family tunnels running.
> 
> Precisely.
> 
So I'll write a commit message and send it later today.
For the case that this one makes it in I will send a patch for iproute2
too. Then we would have at least one application that uses the new flag
for now.

Thanks for all the review,

Steffen 
