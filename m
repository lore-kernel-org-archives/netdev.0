From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 04/17] igb: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:03:16 -0700
Message-ID: <1396119796.2287.27.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <b27274cb1a909c1cf7c5f9f7fc0dc9b296cf575e.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hQ1+GjgSZUo2WUiipJQh"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61736 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbaC2TDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:03:23 -0400
In-Reply-To: <b27274cb1a909c1cf7c5f9f7fc0dc9b296cf575e.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hQ1+GjgSZUo2WUiipJQh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-hQ1+GjgSZUo2WUiipJQh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxj0AAoJEOVv75VaS+3OSbkQAJS7J1BKr1HFdymIuNHwNExH
yKk75tkxGbZEAeDNoFRbtUfs0myIZ+oFZvr0WsRZPoSFHleMqfrIkL3j1LAx2i3s
Scf/969+7VCEKELbyN0FCiJUWSdeDhND5qe4B2dfU8RJwU3dmsdkd8cryXWPx0Pz
Kyct5Vo/HUpfyn5uFxl03Nck1FcqHTA1e1gdQ9axk2Yl/rC2jIUJmtw9Hzq5H3eE
ydiuoHaHmUB0AH+slJSgjc3xdEb1sZ5dFQ/PxuwnQvluQYF5gUYfr+kbMuwl2U4v
ie/Ld91UPblxySuu0JHYGG6F3uqRckMz458P8etjPyO2LJJqdG8ur4DA0CXZNKQ+
MNUg8qcSNh2jFZrvaUpw4+Lv31V/UG3qz3+0P/2JwEMt+SQex69kRfG55+Lu+tO2
myw+A8lMHZ69tcDHR3HmNN09XQTefomBAC0IbkYRhj7PizrPchztT/PwsjhajaW5
0DvfYrR+4RTT0B/BXZcXnviW75/JrblRxHMj/y5zDbwK6e3bdCYXgF65TtoorDgt
lnC/7kOAFw+tKVDPEIgFd6M+6ObvTP4FRzUfU8zYQ0Yl0tb8+8V5qlzFHh7K+WtJ
qcT4iuPYFJGjMO2NHiKRa+w8BPvI8MNGPAvy7ugFQgx7wXAnaOiP8Wxz3P82nAYm
d5J8QXiGBfTUw9GNO2HG
=E1Ag
-----END PGP SIGNATURE-----

--=-hQ1+GjgSZUo2WUiipJQh--
