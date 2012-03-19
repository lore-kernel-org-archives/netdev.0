From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v0 4/5] ixgbe: enable FDB netdevice ops
Date: Mon, 19 Mar 2012 15:46:13 -0700
Message-ID: <1332197173.2307.32.camel@jtkirshe-mobl>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
	 <20120319065208.10959.83135.stgit@jf-dev1-dcblab>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NWoC6CfmFXeJZt1Nfeoo"
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"roprabhu@cisco.com" <roprabhu@cisco.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"chealy@imsco-us.com" <chealy@imsco-us.com>
To: "Fastabend, John R" <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319065208.10959.83135.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NWoC6CfmFXeJZt1Nfeoo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-03-18 at 23:52 -0700, Fastabend, John R wrote:
> Enable FDB ops on ixgbe when in SR-IOV mode.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   59
> +++++++++++++++++++++++++
>  1 files changed, 59 insertions(+), 0 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-NWoC6CfmFXeJZt1Nfeoo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPZ7c1AAoJEOVv75VaS+3OmewP/jA2jNo7WzowvQjEBaBBqG3i
MEciprJW+VmHQFY21te3HVy4F0/OxOgZWU70GxKip7xtW+IDwhEPRRmjR9vVF8zG
sFabmWRBZzDsMr8pjNxFoI78m3SXWSvDlLOR5awpoDgsBdghkXSvrLXwQ8QZ8SK5
LSGJc3GwDa+uHfWoB5v32FUKjnWjWTyDvgnjuqzzrubebe3YylG2icbpJj1V33w7
RvHCfS7dN3i7/wATyMyxZkRgklTZ9ZKURPbtSqK3Cb4bsmtPj7LqQT1/0XSGiOfI
gsF68AyLuE+/EVavnCfsk3lhQKTt0HwibCQxqqgWIE7zGp2/hNN+8ZSlLIr0cwxL
nSse7q4VY5952CA4VliMO1H5f1M96cFEUnUjw2Zdtg6n/P1/SHfJp7uYlDU2sjVT
hpg+TlYz8J3aKrmdk3xSZ/SCIvmOdEoEaBBr6qgDNo36NLNZj7cVnSm3GBVxVFPA
V0TZB/qTLiI9h3NuHa8uVqe+O5iDe0L1KfFC/TbRuP9NVDQCwkSpS6gcmvBZZvkq
2rGqsg/Pgr3u0UEyWpi4gUchrCzy2E9cQ68VYf/ZSQm06jNCi8vaTt0xBYy2Qu+L
cKIGF1j0mOiCpm0Sy+XvqBbAoQfa+5oDbl138DfwT0/5+ySJsdyEZaIIAfqitQRm
CcRtH4ChZqsHARrMP2LT
=D48u
-----END PGP SIGNATURE-----

--=-NWoC6CfmFXeJZt1Nfeoo--

