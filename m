From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP checksum broken since 2.6.18?
Date: Wed, 23 May 2007 21:50:58 +1000
Message-ID: <20070523115058.GA25700@gondor.apana.org.au>
References: <E1Hqnea-0006Af-00@gondolin.me.apana.org.au> <4654186C.8050505@openpma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, pg@futureware.at,
	netdev@vger.kernel.org
To: =?iso-8859-1?B?IlRob21hcyBCLiBS/GNrZXIi?= <dm8tbr@openpma.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3540 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759006AbXEWLvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 07:51:10 -0400
Content-Disposition: inline
In-Reply-To: <4654186C.8050505@openpma.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2007 at 10:33:16AM +0000, "Thomas B. R=FCcker" wrote:
>
> Does this also explain why wireshark thinks the checksum is right whe=
n
> tested on <=3D2.6.17?

Probably not.  It would help if you use the same tool between the kerne=
ls.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
