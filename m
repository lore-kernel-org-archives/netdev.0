From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 14:55:15 +0100
Message-ID: <20081201135515.GA14560@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201072043.GU476@secunet.com> <20081201114000.GB20961@gondor.apana.org.au> <20081201133654.GC13998@secunet.com> <20081201134448.GA21939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:49784 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbYLANy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 08:54:28 -0500
Content-Disposition: inline
In-Reply-To: <20081201134448.GA21939@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 09:44:48PM +0800, Herbert Xu wrote:
> On Mon, Dec 01, 2008 at 02:36:54PM +0100, Steffen Klassert wrote:
> >
> > I searched for your shash work. Is there already some work in progress
> > aside from crc32?
> 
> I started on the algorithm conversion but have only made it as far
> as null and rmd*.  But it should serve as a good template for doing
> the rest.
> 
> If you could finish them for me I'd be most grateful :)
> 
> I'll push what I've got out now.

Thanks, I'll see what I can do :-)
