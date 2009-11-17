From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Tue, 17 Nov 2009 19:16:52 +1100
Message-ID: <20091117191652.615575fe.sfr@canb.auug.org.au>
References: <20091117131637.3a35f898.sfr@canb.auug.org.au>
	<4B025812.6060807@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__17_Nov_2009_19_16_52_+1100_Xtb=DuGdTuPc1sfB"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Anant Gole <anantgole@ti.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753996AbZKQIQz@vger.kernel.org>
In-Reply-To: <4B025812.6060807@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__17_Nov_2009_19_16_52_+1100_Xtb=DuGdTuPc1sfB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Oliver,

On Tue, 17 Nov 2009 09:00:18 +0100 Oliver Hartkopp <oliver@hartkopp.net> wr=
ote:
>
> Yes. You only added the new Kconfig entries (for CAN_TI_HECC, CAN_MCP251X,
> CAN_MSCAN, ...) to the patch "can: Fix driver Kconfig structure", right?

Yes.

> These are the only added items in drivers/net/can/Kconfig from net-2.6 to
> net-next-2.6.

And it looks like Dave will fix this up for me tomorrow.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__17_Nov_2009_19_16_52_+1100_Xtb=DuGdTuPc1sfB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksCW/QACgkQjjKRsyhoI8yKeQCfWWsM+3cyFBAn/zjaIn7Odq3Q
oqgAn1o/AcXJbnmKLtl+mZCSGxo751jU
=U0bA
-----END PGP SIGNATURE-----

--Signature=_Tue__17_Nov_2009_19_16_52_+1100_Xtb=DuGdTuPc1sfB--
