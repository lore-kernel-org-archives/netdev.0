From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Fix possible error pointer dereference
Date: Thu, 3 Jul 2008 15:18:58 +0200
Message-ID: <20080703131858.GN9549@secunet.com>
References: <20080703084836.GI9549@secunet.com> <20080703090403.GA27923@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:49116 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbYGCNTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 09:19:01 -0400
Content-Disposition: inline
In-Reply-To: <20080703090403.GA27923@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 05:04:03PM +0800, Herbert Xu wrote:
> 
> Please check again, we're not dereferencing it here.
> 
Yes, we are just getting a pointer.

Sorry for the noise,

Steffen
