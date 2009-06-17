From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64
 randconfig [drivers/net/ucc_geth.o]
Date: Wed, 17 Jun 2009 23:23:41 +1000
Message-ID: <20090617232341.c4543ff2.sfr@canb.auug.org.au>
References: <20090611033705.20842.75501.sendpatchset@subratamodak.linux.ibm.com>
	<1245048719.5239.10.camel@subratamodak.linux.ibm.com>
	<1245243097.4870.3.camel@subratamodak.linux.ibm.com>
	<6E26D0A1-0FE5-4179-9DA8-FDF0E3D417DA@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__17_Jun_2009_23_23_41_+1000_.izVW4hEBDoJIIBE"
Cc: subrata@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>, Nathan Lynch <ntl@pobox.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <6E26D0A1-0FE5-4179-9DA8-FDF0E3D417DA@kernel.crashing.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__17_Jun_2009_23_23_41_+1000_.izVW4hEBDoJIIBE
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kumar,

On Wed, 17 Jun 2009 08:07:47 -0500 Kumar Gala <galak@kernel.crashing.org> w=
rote:
>
>=20
> I'm confused by the proposed fix as we already have *mdio & *ph =20
> defined in this function:

Which tree are you looking at?  Linus' tree, and linux-next, do not have
those local variables ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__17_Jun_2009_23_23_41_+1000_.izVW4hEBDoJIIBE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAko47l0ACgkQjjKRsyhoI8z1OgCgqkPf9dXeSPtNV2LlDOCBzfGn
VaUAoJedD4+E4MU3dN11tRAzwqt/7AxN
=Cphp
-----END PGP SIGNATURE-----

--Signature=_Wed__17_Jun_2009_23_23_41_+1000_.izVW4hEBDoJIIBE--
