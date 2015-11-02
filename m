From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Mon, 2 Nov 2015 15:06:17 -0800
Message-ID: <20151102150617.30d2e478@xeon-e3>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
	<20150923162650.148fe95b@urahara>
	<bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
	<20150924151630.28129cdb@urahara>
	<5604E357.9000802@gmx.net>
	<b114412a541d4273a9a7a1c0ae4777df@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_///Qvs9JYUd/iyHqb/mkoPRA"; protocol="application/pgp-signature"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	Phil Sutter <phil@nwl.cc>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35616 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbKBXGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 18:06:08 -0500
Received: by pasz6 with SMTP id z6so161747460pas.2
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 15:06:06 -0800 (PST)
In-Reply-To: <b114412a541d4273a9a7a1c0ae4777df@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_///Qvs9JYUd/iyHqb/mkoPRA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Oct 2015 08:07:47 +0000
Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:

> >
> > Well, then we should wait for another voice aimed at the complexity of
> > the patchset before amending and resending me the patchset.
> >
> > =20
>=20
> Well, I perceive that after Sutter has taken over the maintenance
> responsibilitiy and answ

Your perception is incorrect.
I am still maintaining iproute2. Phil is just providing lots of feedback
and new patches.

The size of the change makes it harder to digest, and I do think
adding JSON support is a good idea. Just concerned about the long
term maintainance overhead. Plus I want the other utilities to have
JSON output as well. Therefore this change is going to take longer
to adopt and hopefull we can figure out a good way to do this kind
of output.

Almost want to go to C++ or something.

--Sig_///Qvs9JYUd/iyHqb/mkoPRA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWN+xpAAoJEICnf2CVzeR+Vy0P/isUVlFfUBqjnFPRyJqnHVm4
JBtxQO3L87ShkzSQID0rH/4vOrxSmemgh8Y9xVvzrmxYDrxPsjLysg5s00GOSb+i
1Imtbg9OUPk/V8VPI4C4tm65GpMpWQGD4Ii/7PFHBtLR69rJuynRpuOByf8bgNKJ
vu05jDqhJhpRjP2LlUIapp6qh6zrDyhw1plmV1R5toRuTD3yFI77nIOIvgT9C5NJ
KTloJdvLurX8/yuG1wqCCzZOzEbz4LsZX7pan9wdo9v4Nx/cAftRkcqZ5VeM49H9
N/7rW/ITKmQ5ie/bMl1puEkzAL8lvd+t/UhssTp/ci07wQM73odQU+acnrAw4+kC
TQjZbNc6Ia3bRZGckMsdzRrOl5s1leTOtuRvl1FmHCfcxvwP5ZPXLa8yqogJTRw5
4OFskFJBmWXGQDekAV30cCiyeTZ/mUPyCnWWVWUoTsu8K2LIpwkOUrGSTpTX0yvO
F6Xb4NrNFXOCOQkmIWCBxsdcp+FFzzU511mcRBaLXCjMxR3gcriJqAD8AyV3SLVM
3vRtixQ3bd2cTX11Aube5OBg6kNXfP12IrQXB3d+j+xDWJQb0mPoTJ260H6WglAm
nQFT1BsliRPQfdwFeTlzW+e1I7DjHgjKRL2g3FxWb5itzApCTcxm5xJG7qvN/YRa
lq+YH9kiYAZgdUiFAPVl
=qg0/
-----END PGP SIGNATURE-----

--Sig_///Qvs9JYUd/iyHqb/mkoPRA--
