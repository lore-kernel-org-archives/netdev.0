From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Wed, 7 Dec 2016 10:41:16 +0100
Message-ID: <20161207094116.GA5399@amd>
References: <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
 <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
 <BFA799B0-BB22-4515-AC14-3544A3167B0A@axis.com>
 <ffd3b27c-0bc9-b53b-cc65-c7808595a553@st.com>
 <b126021d-e902-7a53-4d7a-e73ea89a66cf@synopsys.com>
 <A001080B-2DC8-48D9-BD82-8276A9B3BE3D@axis.com>
 <7c7798b5-8cd4-ba99-f526-22d3e06e05db@synopsys.com>
 <2eefdb8f-7e87-6009-6e50-c536d4b95dd6@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: Lars Persson <lars.persson@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        Rabin Vincent <rabin@rab.in>, mued dib <kreptor@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "CARLOS.PALMINHA@synopsys.com" <CARLOS.PALMINHA@synopsys.com>,
        Andreas =?iso-8859-1?Q?Irest=E5l?= <andire@axis.com>,
        "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2eefdb8f-7e87-6009-6e50-c536d4b95dd6@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Thanks!
>=20
> Regarding this subject, I am thinking of making the following adaption:
>=20
> a) delete ethernet/synopsys
> b) rename ethernet/stmicro/stmmac to ethernet/synopsys
>=20
> and send you a patch for you to evaluate. Both agree with the approach?
> To have a new work base would be important, because I will add to the "ne=
w"
> structure some missing QoS features like Multichannel support, CBS
> and later TSN.

Rename should be the easy part. Please do that last.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhH2TwACgkQMOfwapXb+vILRACgjrytlkQeViubuRb8pzcDlSyx
bzoAn0Me7AqZexvyZRf+3sX0BFD1obPw
=Jq9K
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
