From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [XFRM]: Add module alias for transformation type.
Date: Fri, 25 May 2007 15:37:54 +1000
Message-ID: <20070525053754.GA24475@gondor.apana.org.au>
References: <1180067003902-git-send-email-nakam@linux-ipv6.org> <20070525053220.GA24362@gondor.apana.org.au> <20070525.143434.108171372.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nakam@linux-ipv6.org, netdev@axxeo.de, davem@davemloft.net,
	netdev@vger.kernel.org, jmorris@namei.org, kazunori@miyazawa.org,
	mk@linux-ipv6.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2325 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752084AbXEYFiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 01:38:00 -0400
Content-Disposition: inline
In-Reply-To: <20070525.143434.108171372.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 25, 2007 at 02:34:34PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > Could we use the existing IPPROTO_* values for all of these?
>=20
> No, because they are of enums.

Good point.  I've forgotten about these module alias hacks :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
