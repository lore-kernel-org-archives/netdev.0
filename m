From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 8 Feb 2012 12:27:56 -0800
Message-ID: <20120208122756.46aa408c@nehalam.linuxnetplumber.net>
References: <4F27120A.4040106@suse.cz>
	<CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
	<4F27C54F.1010107@suse.cz>
	<CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
	<20120204021457.GA25386@khazad-dum.debian.net>
	<CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
	<20120208020038.GE13296@khazad-dum.debian.net>
	<CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
	<14373.1328683324@turing-police.cc.vt.edu>
	<CAPXgP10-W+yeHJMENzWi7FBkYOaXw6ccMMMT=K9X2bf_Tigitw@mail.gmail.com>
	<10120.1328731572@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/GXzE5UXHspP=x9b8FrXgrl_"; protocol="application/pgp-signature"
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10120.1328731572@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/GXzE5UXHspP=x9b8FrXgrl_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Our customers would prefer network device names of the form
"Ethernet0/0" or "ge-0/0/0" (but I said no...)


--Sig_/GXzE5UXHspP=x9b8FrXgrl_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPMtrMAAoJEICnf2CVzeR+JGEQAMh4NVGXbgoK39Was8sRF/uh
/BQSqu8xO8BWi8yRikMVN4qfKy/JVRT6rVNuOySh/VOhn5SVfkegvSjt/VleaR26
ayB/B9APrRO/00zFZpAFgKfO5UMvq3/HWER5MIXyv+Ts40jxPw6yfNYJHzFq+8XU
OZ+tPdXyY7ZDvg0WVCgDcAUF/KyccgC2ToYHV//Bg48djF7G81eJH5jQQY75EeZR
5+9++aBRg8vuc+m1t+mEfmRtogNMIQa3X5GwQNlVwptV70xzo7hqG4BdDia2MD/U
a06X2T0szlzFmrhNB4gZZZCdhpT9DR1hNMarXYUDpEOxm+Ay20eUamHLjcHMTMIC
oufEU2WaoDQKvYNneB7QwVwyWtXmmZrGIC82lejHOpYlymQiU16pYTmSRbXDTQib
qGdfbNlr3QlxlgDOufes55oKnBj2lm7qKbUHyDRJGuhtMUcLXBF6lLZF8RpbSySg
gzLQuJBS1HsiUjySNnENfOhb5oxS++70kHHXdnT/oAL+Ep21ik/whkiKXFKIo7dw
V32DHWbpA/3oKAhBGEpJ0bRr1xUwra/JRUNivWiEjm81VLKa1i57Qr9h11DOo7RZ
MmScxSEhgwlOiJiGxS5nwCiOV1azR2En5th6oxf/FZwOrfk16Fp8ZtxbOrLS6m6c
2AH6WF/ZIZ5pHTjSCSkK
=5hKt
-----END PGP SIGNATURE-----

--Sig_/GXzE5UXHspP=x9b8FrXgrl_--
