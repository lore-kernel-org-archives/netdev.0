From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/6] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Tue, 11 Jul 2017 17:18:17 -0700
Message-ID: <1499818697.4698.12.camel@intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
         <20170711.072635.185388451319287053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-PVKt4AONKJrgc/wWkBYY"
Cc: intel-wired-lan@lists.osuosl.org, alexander.h.duyck@intel.com,
        kiran.patil@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: David Miller <davem@davemloft.net>, amritha.nambiar@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44760 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752939AbdGLASY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 20:18:24 -0400
In-Reply-To: <20170711.072635.185388451319287053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PVKt4AONKJrgc/wWkBYY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-07-11 at 07:26 -0700, David Miller wrote:
> From: Amritha Nambiar <amritha.nambiar@intel.com>
> Date: Tue, 11 Jul 2017 03:18:30 -0700
>=20
> > The following series introduces a new hardware offload mode in
> > tc/mqprio where the TCs, the queue configurations and
> > bandwidth rate limits are offloaded to the hardware.
>=20
> net-next is closed, please resubmit this when net-next opens
> again:
>=20
> 	http://vger.kernel.org/~davem/net-next.html
>=20
> Thank you.

Dave, this is gonna come through my tree.  Amritha is looking for
community feedback, while we have this under validation.  Sorry for the
confusion.
--=-PVKt4AONKJrgc/wWkBYY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlllaskACgkQ5W/vlVpL
7c5h3w//Ro1syvqIIe2LwWKuDs7NRBsRGCqxZE3HzeZBAtlF6+pPDgqU3FJvNfkK
iXNgznbCXpkCCaMLoy07sLr7ietkQnFsSSdIBimkS9Ttoxc8CScOptxMsVkYPTRt
E/hPssLP6KbD8pFZFtkWDAXkprbxe5fMc+FcdVzci1ddT6UOEGym01HMPbdxh2BL
SuVph+6rmuxJzuLF6ewYEPFNoi5vh/iVUeoWl9MywmDP1vuY/rrsstN5fUdMSoA5
RscTgAhrWeczoiXSiLVhZxAvvnejzjwYnMHgc55GFxmRph1iGhaz65N4cYMvE/G3
Nv37O/vkfv/tNkBdb5tOoZ7iiem9ZBqTJukJsxkd9Hitk4ohzrHqYV/AC2E5fr4E
kgTGvyQlc1Knb2Alwdc0HPMJ8rLcYldkGTmS2RKZWUMcaauJ1nO0zBpVpPksBLfY
ogKxu22nVA4Xk8szEfvib7gvbgoYR5Ztm6HCURqoiDtOW6Nw5FZVakY+kEh/U1EF
9OOMG65kyurzOUW9vXsb7saeQOlHNpR/bdSXphPaB0gXHfqZajCAsQ3Kxt1p2SMG
h6TKhNp/8DI8oL0m41prvwhpveypBznAPrWBj/bXTSezIPJW6rcFgrTrRuN3FW2+
PdnBxQRFA86WKZVmTOIcvKEUBmXsAH3yI+/GBcgShx3cj3Qgyxc=
=MwdX
-----END PGP SIGNATURE-----

--=-PVKt4AONKJrgc/wWkBYY--
