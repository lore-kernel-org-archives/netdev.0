From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for Jan 3 (qlcnic)
Date: Fri, 4 Jan 2013 07:51:32 +1100
Message-ID: <20130104075132.9d6ba2e7f9938b7be55d59cd@canb.auug.org.au>
References: <20130103143741.8027cf717514309b98c5d35f@canb.auug.org.au>
	<50E5D535.6080301@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__4_Jan_2013_07_51_32_+1100_qKNdvzFm4mQ660JA"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-driver@qlogic.com
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <50E5D535.6080301@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__4_Jan_2013_07_51_32_+1100_qKNdvzFm4mQ660JA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Thu, 03 Jan 2013 11:00:05 -0800 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> on i386:
>=20
>   CC      drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.o
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:3285:1: error: static de=
claration of 'qlcnic_restore_indev_addr' follows non-static declaration
> In file included from drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:11=
:0:
> drivers/net/ethernet/qlogic/qlcnic/qlcnic.h:1488:6: note: previous declar=
ation of 'qlcnic_restore_indev_addr' was here

Fixed in the net-next tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__4_Jan_2013_07_51_32_+1100_qKNdvzFm4mQ660JA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ5e9UAAoJEECxmPOUX5FE0IAP/2AtHnuD8Cq/yiJqSh3Qqv1Z
NtkgAthdppWRrAvyFvNbiYnimtLzjh0vrlVePSFXi4+CIeHZOh9PldZhTPGDEIUZ
DnE+vaWsRZWbngOb/tsNv9raLPBIkN2bp67+a9dIz86Llbd1SldY7e0PigEHwmWF
az/pYdXXNV4X7bdcWxgjRx9Z36DMD11nJUpVcy7IMSOTWPWiOhQmfhyT8b3VzLQ4
bwAHvz9rHe9hbumHmy0MwvZ1Tqu7I6ePn2LaSnQedun2tTkRfnxGftzD3CYfC/5j
IRcAB4cROuWP3UgbWzgyxsEUO27qFJ6lB9yz5XX5PmCAeWS7uV2kNrYDcP8oFPxC
4krFSkGbMQKv0t6xeGZhjrNtDRcroVGHVfPrjdBwtMEJXMi+riOechl7l+8pth3Z
u1Iva0/Pg52GNwjZR7Z8eby5QTjymYMLW08x2WRtyuk2fZL97yhVqL+c0BUcyVZ2
KWRcT1nLeSTD4Y2EZq58Yp5yPTYxjZmEDlFmtcwOWq6u9htRQmOFEGxlfX8nJIEv
uqCuxMUpuCGKl+L8ab9EMk4XHmC863VqO4u1qbuEqMvoMeJi5VCCE5e0I+FKHo1D
6JWk1/qGcy6mylN4hjcsSvWK1XPWJvynaOcjObW3MApfAFcGlS3uCLf5tUYj25/9
8g4Ki4R1Xc9L2QB6ZbMy
=WqLP
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Jan_2013_07_51_32_+1100_qKNdvzFm4mQ660JA--
