From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH net-next] e1000: fix wrong queue idx
 calculation
Date: Tue, 22 Oct 2013 03:46:32 -0700
Message-ID: <1382438792.6455.9.camel@jtkirshe-mobl>
References: <1382256924-12598-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i4U9jx6O+758u/55TwoT"
Cc: davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37795 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab3JVKqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 06:46:33 -0400
In-Reply-To: <1382256924-12598-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i4U9jx6O+758u/55TwoT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-10-20 at 16:15 +0800, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
>=20
> tx_ring and adapter->tx_ring are already of type "struct
> e1000_tx_ring *"
>=20
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Thanks Hong, I have added your patch to my queue.

--=-i4U9jx6O+758u/55TwoT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSZleIAAoJEOVv75VaS+3OiZEQAIyJmJ5J0O0DkiPy70uijCuz
NJAALEj0yBLL49LvV89qvEPrEXMdFgUn4H8dZesz2GUbcg2j+cAmF3bD//chTA5V
Qtio4nFeUoaWzYEINBcnrQU552jwaluR+XRbGItnCQL8ZvinSkfkpw49qAz2QJVu
SGqwQbKjvfZTGMbRy8/8DYoiQE+Q8sjyD1B8i0gFgJb7iFFXGFFmmWJDhEaPrCs6
GIU4oN5J5prrK6+sP8ZsnB3JaHBgAQrOrI4HAMafaeAoui83z00LX/b0ImZkjUSI
ihE+O84t5FzHv8sHz3vOomPDjlRLjZfgrQstbAJwtupMLrMMOOuRkyt59sttR7tP
3g8etx10/gN4QlqiTJ4me1TChApIKF8Sh4JOX7ludYnxUpDel6hQBsH8lpY8BBon
Nk4BK1mCo9lT6O5sT4Os2lAtIboAUhQXQKnYC1vr9DViagHJfXOHFzEVxz1RLO6E
KRBuYFFiS9TeXPeoUntjh8hQryQnX0I4/869xXPp950diPRWl+WXcbuApiieTa+7
wwYrf9hT8NwEg2RhFpfW0zJ544iRL8cwb2LrDJjiHaeelTMckXHnBYbf2V9MybEG
IvRbwzsfQH0UFvZGUBvZS5vU9hsxYfswACUCoYcuCyjfsZP7EvWfq2oUfavSUPVq
jvRvn0GUlpzMhaw0j1AS
=v3ip
-----END PGP SIGNATURE-----

--=-i4U9jx6O+758u/55TwoT--
