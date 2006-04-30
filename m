From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: make non-operational after being stopped
Date: Sun, 30 Apr 2006 22:23:33 +0200
Message-ID: <1146428613.17814.32.camel@localhost>
References: <20060430173353.16363886AB1@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bMPlIEKTpIRpqSaScppL"
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:61667 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751024AbWD3UXm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 16:23:42 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060430173353.16363886AB1@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bMPlIEKTpIRpqSaScppL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-04-30 at 18:33 +0100, Daniel Drake wrote:
>  		dprintk("deauth without deauth packet. eek!n");

>  	dprintk(KERN_INFO PFX "got disassoc framen");

>  		dprintkl(KERN_INFO PFX "reassoc request from unknown networkn");

>  			dprintk(PFX "Not probing Channel %d (not allowed here)n", si->channel=
s[current_channel_idx].channel);

It seems to have lost some backslashes there, or is that just me? In any
case, it won't apply properly, can you resend?

johannes

--=-bMPlIEKTpIRpqSaScppL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFUcwqVg1VMiehFYAQKI/g/9E5YMzBR6mvwtgyzwkLOKbXAihDmXyvhA
CH2YHgZ+TXrWc5Yxof8+BVqT77Y9qAPV3fWuqCTW+RTYWcdpEswhk28zaycTMnAJ
1bEIGKlaCeYyl5lxwRHhmnPGFgiCSwBHd023fZU/gIzxPai9vhEUZSRu0L5ZN9Rt
Gj51K2mommuXo4Da2hhCqjJvrTl4HsiEhPYx6jle+vFKLUrU9wJk3tbru6feSpjN
hioYPkf1Qeh+Th7Ij73yZK0LmoRV6RWx+/SOnXgOmJm8g7b5Uo3WMABMqoyChy2O
pbqHimTeOZrr7ECrUyk9NT9vLnkgZUPWmtN4vs4N1Vgb8+dfTKntGHhOIbmy3/5R
ypg36gOwW55jTHilH5x3ldizr4SrK+iv0kzqoQGVhiMYRwSjK1E+ajAUWTakGcgn
8upYeMpVxnb0AfgzO+i0PIlMFnxvnPhEslgS1HPYURKa/43B65EK3+vna+b/Wyud
0pDhsqHa4brZ/Dbc7woNE+WRPsASS6x5OsQaWPn0RM/kjUDNJ8RVwqG8XDdOiApQ
M06foZmnpoyUnGhVM48eGNhsrFnJgiDEZNLEIUchahXIcV/E3KQYzClK6D0j5ouK
G4lemD0r8v58Wk47xjZXeGaiPo1CRghHsd8ViQ8NWWONMBIhh2HsSz6CQd2R4Tt1
3NyrqbWZZKI=
=wn67
-----END PGP SIGNATURE-----

--=-bMPlIEKTpIRpqSaScppL--

