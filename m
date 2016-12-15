From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 11:45:13 +0100
Message-ID: <20161215104513.GB406@amd>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161215094517.GA406@amd>
 <c3d2816c-3c50-fd4b-16ea-912b321d51d0@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="eJnRUKwClWJh1Khz"
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        alexandre.torgue@st.com, romieu@fr.zoreil.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c3d2816c-3c50-fd4b-16ea-912b321d51d0@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eJnRUKwClWJh1Khz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-15 11:08:36, Giuseppe CAVALLARO wrote:
> On 12/15/2016 10:45 AM, Pavel Machek wrote:
> >Giuseppe, is there documentation available for the chip? Driver says
> >
> >  Documentation available at:
> >          http://www.stlinux.com
> >
> >but that page does not work for me...
>=20
> Hi Pavel, yes the page has been removed but all the relevant and
> updated driver doc is inside the kernel sources.

Ok, perhaps the link should be removed, then? (Along with the bugzilla
link if that is not going to be re-enabled?)

Is there documentation for the hardware somewhere?

(As something is very wrong with stmmac_tx_clean(), either locking or
interface to the DMA engine.)

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--eJnRUKwClWJh1Khz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhSdDkACgkQMOfwapXb+vIeOgCgvdg6UO3Rt9WMjPRKq2zkGb0i
l+IAoJ100PLmV2OPxrVmwAlAIx+Mxt93
=z5um
-----END PGP SIGNATURE-----

--eJnRUKwClWJh1Khz--
