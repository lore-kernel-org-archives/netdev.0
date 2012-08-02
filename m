From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: reduce Rx header size
Date: Thu, 02 Aug 2012 13:28:18 -0700
Message-ID: <1343939298.2132.42.camel@jtkirshe-mobl>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1343920538.9299.200.camel@edumazet-glaptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ndG3r3MJK3aUTprXz6Jz"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2858 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547Ab2HBU2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 16:28:19 -0400
In-Reply-To: <1343920538.9299.200.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ndG3r3MJK3aUTprXz6Jz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-08-02 at 17:15 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Reduce skb truesize by 256 bytes.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> Tested on my machine without any problem
>=20
>  drivers/net/ethernet/intel/igb/igb.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)=20

Thanks Eric, I have added it to my queue.

--=-ndG3r3MJK3aUTprXz6Jz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQGuLiAAoJEOVv75VaS+3OSg4QAKfG5fmhcb0D4HRU/C02HgtJ
1vPfku36bBhnRjWtJcYwovXqscP6mtfWPFhE3ba26wL6AHVplGFAsaPR9zECD88f
Hw86EEpxPTRLxY6fGFXWP+dkDCaCr44hdd4KKo7JivXyaqly6TrnwsADLj1fmq5K
7slqyWbVJSPgNYFk3i6FYZm2BKWACucFCtjDbUVYB3pauwUL+r0/whZiH1IIyTwP
/puTDlz6/elLxY2uZiUE+F31R9gTL9nA8PcNoxt0hLKdrOfcQw4xYyL7sysSLgWL
mZS2Lhw3wNTe8lfKofNv1B0aoIlDOMyH66fcbeazoy4Fx/bThiBf9iOdyZmXKSAK
eRMYcgjPFI9Rzfzy5ZwUYxidAJgdi8+nfynYVLRu96z+omHXC3munjsnNJaPh4Ov
UNNQW0O/D6dRLJYTJcaXpwxyuTNWyhMitR0thXfanMEQnfSrY7WmHXPlzLxRP6IN
nlQVa1s+kNe8FDu3vQ4a73XxgYICgVr4m/tENFzWDKsDFAvVHlVenkuzenHDvTYB
6qFelGn9QW9o1IBHjXQDFRh3bQAM3fuzOYWEmONPpvPq98noM1v0fr5wXlw9f+te
bSGDYX51GgsZEL/enARKQ/mO8d7tWMgziq7wUq2Y2vKo/q9setmMVi9o8T5J3jMJ
YSTtq+ZvOCLdJ3I/7/iB
=6Rex
-----END PGP SIGNATURE-----

--=-ndG3r3MJK3aUTprXz6Jz--
