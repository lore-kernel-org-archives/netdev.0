From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 17 Aug 2003 13:13:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061140404.29559.0.camel@laptop.fenrus.com>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com>
	 <20030728213933.F81299@coredump.scriptkiddie.org>
	 <200308171509570955.003E4FEC@192.168.128.16>
	 <200308171516090038.0043F977@192.168.128.16>
	 <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
	 <200308171555280781.0067FB36@192.168.128.16>
	 <1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
	 <200308171759540391.00AA8CAB@192.168.128.16>
	 <3F3FB275.3090601@davehollis.com>
	 <200308171845560303.00D4B163@192.168.128.16>
Reply-To: arjanv@redhat.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pvy2wwBMrUDO3qFcJjuW"
Cc: David T Hollis <dhollis@davehollis.com>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>,
   Lamont Granquist <lamont@scriptkiddie.org>,
   Bill Davidsen <davidsen@tmr.com>, "David S. Miller" <davem@redhat.com>,
   bloemsaa@xs4all.nl, Marcelo Tosatti <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Velasco <carlosev@newipnet.com>
In-Reply-To: <200308171845560303.00D4B163@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-pvy2wwBMrUDO3qFcJjuW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> 1. hidden patch is not in the main linuk kernel stream.... why?

because arpfilter is a more generic way of doing things like this, and
that IS in the main linux kernel


--=-pvy2wwBMrUDO3qFcJjuW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/P7e0xULwo51rQBIRAnUUAJkByJSuyHz4tv/7BD5akZlnh7Yl6wCfVinj
ER4FDcOJEPHlaPhF5XFOSlo=
=iRkb
-----END PGP SIGNATURE-----

--=-pvy2wwBMrUDO3qFcJjuW--
