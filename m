From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Sat, 1 Jul 2006 13:38:05 +1000
Message-ID: <20060701033805.GB29803@gondor.apana.org.au>
References: <78C9135A3D2ECE4B8162EBDCE82CAD778C6B07@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@osdl.org,
	Ravinandan Arakali <Ravinandan.Arakali@neterion.com>,
	sivakumar.subramani@neterion.com,
	Sriram Rapuru <Sriram.Rapuru@neterion.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:56582 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S932576AbWGADjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 23:39:01 -0400
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD778C6B07@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leonid:

On Fri, Jun 30, 2006 at 04:46:56PM -0400, Leonid Grossman wrote:
> 
> If ECE == 1, then set it to one for all datagrams.
> If CWR == 1, then set it to one for the first datagram, and set it to
> zero for the rest?

Exactly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
