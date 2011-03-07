From: Sven Eckelmann <sven@narfation.org>
Subject: Re: pull request: batman-adv 2011-03-05
Date: Mon, 7 Mar 2011 10:01:36 +0100
Message-ID: <201103071001.39111.sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org> <20110306.181432.104062354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2761221.4oCbEjV3Ee";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45907 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896Ab1CGJBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 04:01:43 -0500
In-Reply-To: <20110306.181432.104062354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2761221.4oCbEjV3Ee
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Monday 07 March 2011 03:14:32 David Miller wrote:
> Can you like sync with me when you have less than 20+ patches queued
> up?
>=20
> It's too much at once to reasonably review, and makes regressions take
> longer to bisect when people hit them.

I'll try. The problem is that most of it is one work package (the removal o=
f=20
orig_hash) which I got in this amount of patches.

What do you think about another pull request which only has some of the=20
cleanup/fixes and leave the rest for the time after 2.6.39-rc1 - so it may =
get=20
into 2.6.40?

Best regards,
	Sven

--nextPart2761221.4oCbEjV3Ee
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNdJ7xAAoJEF2HCgfBJntGPqcQAJlA9kI1b2V42Go3Oha8FS2P
tMEXBpxWx7dP1hyEFTlkwQ/JqUPrVcSUNbr5i21st0SPJuYcMFFlY+umB8C7PKeX
RllJ2dnKZnMe7XeugfNbTy74wbafDSO+SAPr7+Dg2985S4pBozoONg/EwygrQ5hs
EWbUWenaWbxYleJOcGSRSaki4Bdd8PsTGBUC3A3hHH7q8L4/1knxck8TTNz3lt+q
E0Cmh01C1fU53KmEL4iTua++4JxaTiHznO1WEEmzsBqRbYLZeCuCeEYQ/RQj6d7C
uxZRXc+IAQep8z4r5W/OBt2iGjIzyzx2ld1N1/jILNa8ohSjCY+PvWPk7JniYlfe
Wc9Tb6hBbChzhPIxWop/PJoIJxJmWYBseJgzeQn8pwE8CHI4VhH00GlqGSQKJhmk
gWxikJmvSjP+RGuaVGG/rXnKH+a3nIMJ9xjFhHzNiezbnH5LjDnL7Il0mHtXhhL2
ynE8lr/yzMy5NSiQ1uiF/r8VpoR+IQNDGeD2xEZh81R2xX7CahJr4+nAyy0uCZH5
ko5ismzFJLUvxTxqxkJmB27XW6qHFJeWzXTGETsY47++HKwQ1TFqhmX2mPcN26CQ
FB/UNvGx2O4ERxaW/kTrPLXQc1bfNEcpUDN2VjJwzQcchqsjULPULAGmEkYIjfqN
xGV0I8MUJdCOBH3lYw8R
=C431
-----END PGP SIGNATURE-----

--nextPart2761221.4oCbEjV3Ee--
