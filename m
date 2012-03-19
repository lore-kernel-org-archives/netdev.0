From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v0 5/5] ixgbe: allow RAR table to be updated in
 promisc mode
Date: Mon, 19 Mar 2012 15:44:35 -0700
Message-ID: <1332197075.2307.31.camel@jtkirshe-mobl>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
	 <20120319065214.10959.12406.stgit@jf-dev1-dcblab>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Fm1qnAjxHJahVP6IDtDt"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13633 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919Ab2CSWo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 18:44:58 -0400
In-Reply-To: <20120319065214.10959.12406.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Fm1qnAjxHJahVP6IDtDt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-03-18 at 23:52 -0700, Fastabend, John R wrote:
> This allows RAR table updates while in promiscuous. With
> SR-IOV enabled it is valuable to allow the RAR table to
> be updated even when in promisc mode to configure forwarding
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   21
> +++++++++++----------
>  1 files changed, 11 insertions(+), 10 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-Fm1qnAjxHJahVP6IDtDt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPZ7bTAAoJEOVv75VaS+3OxOkP+QGtlirD37v3qBXw/+z6a7iy
BnYSnyA97TZ8uu3q+7C5YcIgKcAMNWGb/xfOQGNt6IkD0ewvwjxrxL2qP6sRC6Wb
zoM0/k/bhJnkYEv4y0fpmxudUBlwvKAhF17wh1VYnHPo5cHHxusB6MM6DYJMCU1s
SwMXAIAmqw2sxbu1gap/hdFf6P8EokwsyLglciSr4b4cuDpoz2Bq4FrIvUB8U73B
M0j3djqn610zjYuizJHTWcPOG0uLaIl69F/x+ckEP298zs5k1M1rh5XvCoK5Aljd
ggUZKiItMAzT0a8nz7s8c9z0tR3Jn/t++drs9kKtTpoGEmcHpm8sfZQ3e2RW7c+H
UB9dwRmSS+8Tk1oXXU4qEQsCnqg5dDBU9JaRJHzGdhpRW5xR6jr/G6CSEn71Wadz
GM7fqYcBbxbgbxCr7B6tsGsbQPDPh4s8aYLFf63CFv/yHc7pUTh6XHu1tCuYUZUl
oFULRRu3OdBwSf2HQ4KsedLu8l814RYIjmUWrtQ7X9N0SAUUOA0YN1jegySuPwra
LxsA97nwuhu6rqXk7QAymh9in8clDfyORflwfL3EyK8FT/z04FwgTD/fQBuGu8ij
ouF75ZPreVLCRdfpFeUYDubf9zHomEh6TCm5gLewnpGwi9twEO4Dl0pGThFq7eXX
yOD8JmkGewAp2BiQScfV
=H7tL
-----END PGP SIGNATURE-----

--=-Fm1qnAjxHJahVP6IDtDt--
