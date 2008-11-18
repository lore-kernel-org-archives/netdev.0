From: "Kaplowitz, David" <dkaplowitz@irobot.com>
Subject: multicast forwarding
Date: Tue, 18 Nov 2008 12:03:18 -0500
Message-ID: <1227027798.8765.28.camel@irbt-1279>
Reply-To: "Kaplowitz, David" <dkaplowitz@irobot.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-PU0wY0oonxT1+OKTW2Vm"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.irobot.com ([206.83.81.187]:15986 "EHLO smtp1.irobot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756163AbYKRRSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 12:18:32 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PU0wY0oonxT1+OKTW2Vm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Greetings,

I have an interesting difficulty.  I want to be able to grab a multicast
stream from a machine (192.168.12.13) and forward/rebroadcast/rewrite
it, such that the packets seem to come from my DMZ host (192.168.12.12).

I have been trying an iptables solution, but that doesn't seem to be
working at the moment, and it was recommended to me by =EF=BB=BFj_engelh on=
 the
#iptables channel to ask at this address for further assistance.

Thank you for your time and effort on my behalf.

-dkap


--=-PU0wY0oonxT1+OKTW2Vm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBJIvVWueMqKH4VzoYRAvpJAJsEgnnw8JNsru4Zdi2In5nyBF/GVACeMCE5
EiOTJufsI71JMLfcbUo32gw=
=ep9W
-----END PGP SIGNATURE-----

--=-PU0wY0oonxT1+OKTW2Vm--
