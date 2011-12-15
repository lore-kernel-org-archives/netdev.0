From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 15 Dec 2011 14:16:46 +1100
Message-ID: <20111215141646.02d82d2c0a905076ffb130d8@canb.auug.org.au>
References: <20111215135330.94caf28045fd307801fa5ef9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__15_Dec_2011_14_16_46_+1100_ruHT9CT.fcg8LQ5/"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from calzone.tip.net.au ([203.10.76.15]:49415 "EHLO
	calzone.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809Ab1LODRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 22:17:00 -0500
In-Reply-To: <20111215135330.94caf28045fd307801fa5ef9@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__15_Dec_2011_14_16_46_+1100_ruHT9CT.fcg8LQ5/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 15 Dec 2011 13:53:30 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-agn.c between commit 81670a491849
> ("iwlwifi: tx_sync only on PAN context") from the wireless tree and
> commits from the net-next tree.
>=20
> I used the version of this file from the wireless-next tree (where this
> conflict has been resolved).

Unfortunately, it was the wrong resolution for the net-next tree due to
other changes in this file :-(

So instead, I just used the version of this file from the net-next tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__15_Dec_2011_14_16_46_+1100_ruHT9CT.fcg8LQ5/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO6WaeAAoJEECxmPOUX5FEgiMP/iC1Wj45b4vsXRHc32nurDtQ
tYVpSSb1XpXLIjZnVjiBH2Kv/Z21dTRH+IRns0oZthihpIwvy479cOrs5AA7qPWj
N/cIHXhAfIgTltLcHb4c/VKl1nUyi3NZaVLWTfelm/bfelbyc9Qp7SWmSAatUf3e
uewEOl8Z7I7IgqPCKrUsZj9oqtkWGjg90VB2ng0RlkTFj/dZUNPNYa9BVU0nmtBm
w+QRH7z/F+6QR4y6ywJjyT/nvLnPy+EUUZiUyFB7e4ODc+O9zfIR596DcfMeoVCC
BjCv8iNvdf5hW0rDZjwonhsnDccji1/uvlWapXq7LXpL9+IYvlvcIQjHVkBDbhHw
afqIK/dRPMFymwY0fY37uHKRw4g+0a/wP9tqwOXwnDm9+6ClTjURW7QE9NEnKSA8
ykgfOGnNfPgqmLtbQW0NnTT7QHEuRb0xxiC8sjAOmmdb2GTTRQesUxjlrDuwQUNj
UMOvIHbVbdIx7JPQraR06YHUS0n8VTBR/RpFPbcqdqFwGkuj+tZfsXU3PN0R7NPK
dnXJNOV/r4r+4bhjiICmpz55wGbV0pCDFXPvhHvjkd46BTYFoocd+eAkPPC4TK2S
4elXpUWAV6BMkNffshjXrzAN9QP1oZXFeYF3HfFRT5oQs6oNSLTEVNnW5KYsqtP4
7wFkf6zzyw0lGzNxpep5
=SJZB
-----END PGP SIGNATURE-----

--Signature=_Thu__15_Dec_2011_14_16_46_+1100_ruHT9CT.fcg8LQ5/--
