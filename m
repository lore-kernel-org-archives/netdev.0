From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fm10k: Report MAC address on driver load
Date: Thu, 18 Jun 2015 15:49:35 -0700
Message-ID: <1434667775.3530.79.camel@intel.com>
References: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zPKiQJE8mA9UFI381Hbi"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41055 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbbFRWtf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 18:49:35 -0400
In-Reply-To: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zPKiQJE8mA9UFI381Hbi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-06-17 at 20:12 -0700, Alexander Duyck wrote:
> This change adds the MAC address to the list of values recorded on
> driver
> load.  The MAC address represents the serial number of the unit and
> allows
> us to track the value should a card be replaced in a system.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_pci.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Alex, I will get this added to my queue.

--=-zPKiQJE8mA9UFI381Hbi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVg0r/AAoJEOVv75VaS+3O18sP/RSrFav+cSqh0qyWcwLw6Y5k
Jz9X7jFNpbFaiJiZ4pfMNPGcfiguHOMPNk6786XIM+wvTKcQ9D8D3BglWdy/C3AF
dHYERsz32Mp+ZjLG23UOSyuZNE5VcWqFklDCffb7m0VNflk8Bzd7QLiBdB+ggZB4
GVyEz3jZuvN0ZoVwoMZEyzGtHd+RaJAZ0Y/IN+gP0CBTuQpNV5Qpel99taEi2pMG
SgzqqBJCZpnMueJm4yoLulPrYlfiSVtmJKVHLifSfK7Fk5X1ao4AmHhkeZeR0ZG7
NYGk90fDACeuhX8kUhxquvPm6FsdiwFXAN1RVkxGCqAZ8KAw/G2YKWQhxJg3IL2f
n2IhvjYbzYbcakcMSOU1hfrN51sNq8PKGzgqx2R6oNh33zjtfcC3QajLCALSWBi1
muM2c2q1AzhVfGb22G4iPt96ffkCxB2tcBBysqOfzMv1Yc+RvRCGlfL2ilDh27qb
8udzV4z+G8IOtK4eDYUH1QJGJPQBWUnPiKRI9foX7oQBSb6u4TY8npGjpGsxIP+j
Yq43O8OOAzcxSRIE5YKFXpdnHcdIoUdgBciUcGo4rSzHAJAtvhinnZBJkhMrkx9D
GIuy9FTy2349vhzqpDrztTK6N++H29U8NVc3SK5+HlF4QMO9wKbui8sQSyz8p+Dp
XC/qDcg1Sl65z6TBLHUG
=P8nN
-----END PGP SIGNATURE-----

--=-zPKiQJE8mA9UFI381Hbi--
