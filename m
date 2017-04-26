From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 4/7] ixgbe: use pcie_flr instead of duplicating it
Date: Wed, 26 Apr 2017 15:09:25 -0700
Message-ID: <1493244565.2124.5.camel@intel.com>
References: <20170413145339.20186-1-hch@lst.de>
         <20170413145339.20186-5-hch@lst.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-TU0ovrfIc01iSJfaN5gq"
Cc: linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23036 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967438AbdDZWJi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 18:09:38 -0400
In-Reply-To: <20170413145339.20186-5-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TU0ovrfIc01iSJfaN5gq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-04-13 at 16:53 +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 16 ++--------------
> =C2=A01 file changed, 2 insertions(+), 14 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Sorry for the late ACK.
--=-TU0ovrfIc01iSJfaN5gq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZARqVAAoJEOVv75VaS+3OvhcQAJR4igUR1x0zklBYqQ+uNahr
prxixmgMDSylAL+UwlSEmgWXfj/LLNFPZmguMyIhK/uMre5iAu/BbylErOheDrDI
XzwqAWKdJj6uQ/EVpac6gn3OGjauunNFevkECxtoK5wkhp82MPVBiMlkobOULWLN
h483gMsMQn/5ZGX8r3edsOHV+sVRFrvIop93AEndiHCruw2PfoY5URtCCJAFXyyl
o/foFA5QJwVIrzdZ2rVDa94xN9HHBV3QXPqBI6NwK3YkGaKKEOW8s6S0lW3u8FTi
jBOATwyk+NMbUSxFF338ZjlDp/jNVt3Wfhew+/XIrCcjTMYgVwxzCIbzb6jI7woE
FCbicg4SWq0T9hISQMHUUPj3F7jUnLHq7GT0Vy9qsBbaCcH6h8sCciDOcl94KmmF
m02mcxd7AVVlEc4fJ4EU0sfzupAbHbZm21C4aVEwmr+ujf8DGCNk6i6BU1oE1Mt6
PCJL0fUOvcfiiCOv6y5hefwBpKH1fpta7C/MbnXW0WDOgmDz/j7DEv69z/BlJezA
evG6Gcbc9k7iVQ9oo8EXh0nS0L/Vsxwr3tsZdT6AMrnzHzrzsOY9tWn4lNmW8XjV
xHCWpCH/RXYBHJYyMQs2p15FKN1UY1QbG5sJ7Ggmc9cVppk7+a+sZzgB1OXxcPi2
VeJluyLwN/tXNXbkEbp2
=nNst
-----END PGP SIGNATURE-----

--=-TU0ovrfIc01iSJfaN5gq--
