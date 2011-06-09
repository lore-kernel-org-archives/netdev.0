From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 9 Jun 2011 15:39:04 +1000
Message-ID: <20110609153904.e602b317.sfr@canb.auug.org.au>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
	<7CA9E653-DABC-470C-BCA6-905D6EBF9283@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__9_Jun_2011_15_39_04_+1000_6kpAXfJ2tYt0zzV1"
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Greg K-H <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <7CA9E653-DABC-470C-BCA6-905D6EBF9283@kroah.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__9_Jun_2011_15_39_04_+1000_6kpAXfJ2tYt0zzV1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

On Wed, 8 Jun 2011 22:17:55 -0700 Greg K-H <greg@kroah.com> wrote:
>
> Sorry, this is something that Linus asked for and will be going to him
> tomorrow with the rest of the staging-linus branch.

Yeah, I remember the discussion, just not a conclusion.  At least the
x86_64 allmodconfig builds worked before I merged the net tree, so that is
something.

The powerpc allyesconfig build is going to be interesting :-(

You might like to check the build results at
http://kisskb.ellerman.id.au/kisskb/branch/9/ sometime tomorrow.  Or
point your janitors at it :-)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__9_Jun_2011_15_39_04_+1000_6kpAXfJ2tYt0zzV1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN8Fx4AAoJEDMEi1NhKgbsqtQH/2q4/o65CQRamoGjKezeBIzo
AvQk+kdnGwpdoquIa1/BS6CzFiNV8xZkiO1DK4JyuRpLo/jOd4YoQJND3PZgH0ls
S0DviiVrqzh5nZFKf4u1hPayt5nMTpVvBCgpo3XueRRIcHnKpyMFAOEDv2Lm14FZ
y25u1AovA1AIsSBbQ3KaJprfa2ffVMVlO4JajVvU+78W7831/GrRE0cmZShhfarZ
aBHPNBO1a4uS6Pg6NMK6UtkiZhuvufZBRu5Pybq2pWYC8ndgcyvkFy4wqbM6JBPw
ucaEASj/ssiWNlD7vR1C/DH8rSWqq/+u7lhhimOCHRoi88C0iBje+JZOfXSi5Ks=
=omz4
-----END PGP SIGNATURE-----

--Signature=_Thu__9_Jun_2011_15_39_04_+1000_6kpAXfJ2tYt0zzV1--
