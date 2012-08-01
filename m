From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: iputils git tree
Date: Wed, 1 Aug 2012 00:16:20 -0400
Message-ID: <201208010016.22035.vapier@gentoo.org>
References: <201203182107.43855.vapier@gentoo.org> <5018A0A8.4000107@linux-ipv6.org> <5018AC1E.2010704@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1658824.rbhOx0vd9y";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Noah Meyerhans <frodo@morgul.net>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55443 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab2HAEQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 00:16:22 -0400
In-Reply-To: <5018AC1E.2010704@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1658824.rbhOx0vd9y
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 01 August 2012 00:10:06 YOSHIFUJI Hideaki wrote:
> Hello.
>=20
> (2012/08/01 12:21), YOSHIFUJI Hideaki wrote:
> > (2012/08/01 11:46), Noah Meyerhans wrote:
> >> On Sun, Mar 18, 2012 at 09:07:42PM -0400, Mike Frysinger wrote:
> >>> the iputils homepage says to use:
> >>>     git://git.linux-ipv6.org/gitroot/iputils.git
> >>>=20
> >>> but attempting to clone from that gets me connection refused.  the
> >>> gitweb is
> >>>=20
> >>> still alive though and shows recent commits:
> >>>     http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=3Dgitroot/iputils.g=
it;a
> >>>     =3Dsummary
> >>>=20
> >>> so where can i clone this tree ?
> >>=20
> >> Hi all. The iputils git repo still seems unavailable for cloning. Is
> >> there any possibility we could get this fixed? I was able to clone from
> >> git://git.linux-ipv6.org/gitroot/iputils.git
> >> at some point in the past, but it was more than a year ago.
> >=20
> > Sorry, I'll fix.
>=20
> DNS entry has been updated and you can reach it after a while.
> I am sorry for any inconvenience.

i can clone git://git.linux-ipv6.org/gitroot/iputils.git now, but it seems =
to=20
be pointing at a different clone than is viewable from gitweb.  it's stuck =
at:

commit 2384927c0ac1bb3ad21966350644d08faadb7a76
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Oct 6 20:59:20 2010 +0900

    iputils-s20101006
=2Dmike

--nextPart1658824.rbhOx0vd9y
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQGK2VAAoJEEFjO5/oN/WB0FUQAKSsO7rXjIPAYglWuDKnhZKb
zebK7tMvKa2Pq9TAg5Gvgmt1Jty3kJQwRbpRuMODThdHmy0nKYltOMvpfd+SYkE4
/qDMLcMfz7X08xcTJd82xCXeFrIeD7VyQRlnR8FT2LySFvgVS2FWsKUcS+rpEyif
L0lrvaCHe8Y1DosQZLr4hiCE/wzP51+fyA4sYvHqXMop3lSJfjHlUsqD/4K3mH/Z
BSfbE9OeLVQ3/53Hs84NbiIhQ9XMDnBO/bLgppxuXumw+X9Vdp4S12XstxSBecOa
w9okNducfjNoE4dHiWrVVoW/cMsbrG0tRlRdxwcamt5sc/bsrf7QGuuOpHSr6VSy
2yizM6K9q0lf8wfAjVf8xmrHV98DxVncrNkEb5s5Y4LdGK6AiXvaU+Uq5jPw+l/X
0MnPbc42NvSmvpLRUUNDIaMSl6bDyJ113LIwX2RQtwOmf3GsOv/or3RUEEBTsiKV
ia6/09U4Uoe7U5ivNa9GjtAGnoMoswmp9OJqbHx/wfcxgAM2T1S2f+3ZwU4X7Vqd
7Rlsv97lDY2GO2opbdeIeyQg2ltM6fglpGsiqKxmlNjv7GQljK5ZiFC8qek9jjY5
ZyTxFE7+amgfp5cQQHzO9BJkrBpJj/V5TFdelJSjQsck7BWoxQljT0LqrC19zGOp
ZTf8pHo0knmMQvlk/5LZ
=kWz9
-----END PGP SIGNATURE-----

--nextPart1658824.rbhOx0vd9y--
