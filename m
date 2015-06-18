From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fm10k: Report MAC address on driver load
Date: Thu, 18 Jun 2015 16:49:41 -0700
Message-ID: <1434671381.3530.81.camel@intel.com>
References: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2BcoNn38rtWbSnsBsQ+m"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10009 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbbFRXtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 19:49:42 -0400
In-Reply-To: <20150618031252.15654.56639.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2BcoNn38rtWbSnsBsQ+m
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

With the recent fm10k patches that Jake submitted, this patch no longer
applies cleanly.  If you could re-spin your patch against my next-queue
tree (dev-queue branch) that would be much appreciated.

--=-2BcoNn38rtWbSnsBsQ+m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVg1kVAAoJEOVv75VaS+3O85wQAIJoCAX6YTST5nlrJQlvEIcw
IKBhwWDavBwnyCIU6VmdkiYslxUtxHD44VHGpyLXuxK20MxYhYPWqm5DUfPQnfOk
5rjCUkLXfOgkkg1oKizdSOA4iwcz0Mw3C8nsv0Y7pWpGik7TurtuA+eR1M+BCUxG
MrY/csFcDBEZn6ibdOgvht+98cc01WiuLSU77b15k9sI/jkL6vWQykAd2FLZQeP7
6Y2F0MV4tRGSYWWp1EG5ucT3/h7SeZ0d3JTdCr6zPnCrkXCDgxAuLHdjQSikB6cB
B7Zi0G1zOHEh11NaFGfCsd0LpmSfqgUKqVVSRHbHaXsl8sPOquhCnmCQsvqsPxre
EjAnKGE3GJ5rLj7dh0TNmkqp09/uh+SsvOOgwSbvxXsmRRx1vKHBhisQBrMG1nsM
glpIGj6UY56KqRcALaHBSurS0Gv8D8xzIPw07yDrl9HkLpV6f9aC4Vcqq3XnHO4Y
OIu0mfyIiifXQIAafSsIwxam3z7rzcte6vBACUdKvAkvUmQ1CFSPXp90BO49zd4a
dmFDsg3dhw6Xtwlg/+s7qRfWC4tnD/V8NmB6KhL+rWOVRhxFzkQNLKsGmA1fYeSx
nK7WYeW4OsW9LIjRj/kZfBno/4Ll4oTldpa6LigeETQcd7cIwTju1Br0EHaXGFZh
FbQAO8zrDD15LHvrSPaB
=1fa2
-----END PGP SIGNATURE-----

--=-2BcoNn38rtWbSnsBsQ+m--
