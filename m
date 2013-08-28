From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next  2/2] ixgbe: Get and display the notifications from
 changes of the Rx vxlan UDP port
Date: Tue, 27 Aug 2013 21:53:08 -0700
Message-ID: <1377665588.2005.39.camel@jtkirshe-mobl>
References: <1377665218-6760-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377665218-6760-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1Bu5vT7Gu0BVNYdIBTam"
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28550 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597Ab3H1ExK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 00:53:10 -0400
In-Reply-To: <1377665218-6760-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1Bu5vT7Gu0BVNYdIBTam
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-08-27 at 21:46 -0700, Jeff Kirsher wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>=20
> This RFC patch showcases how drivers can use the changes in
> "vxlan: Notify drivers for listening UDP port changes", and its
> sole purpose is to help people test the changes introduced there.
> This is not meant to be submitted for inclusion in the kernel.
>=20
> CC: Don Skidmore <donald.c.skidmore@intel.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 25
> +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)

Just to be clear, this patch is an RFC.  I missed putting it in the
patch title.

--=-1Bu5vT7Gu0BVNYdIBTam
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSHYI0AAoJEOVv75VaS+3O4/gQAKXEDxT2QLEOraEF6KYYwaTe
n56BpV64aGBHOZwYZo135nmZfIrBUVH7MTfM8OwakMKc/IqQhmnpXUiDRyqVmSsL
LsP2CZFs1SLYF4FjK2w9uuJjdRu/UQOkyTAUoUyyDJhD8aSoKLZHe2qYg84Z1wsL
5cuOIxHA+0PYwiTxUssYsAfHxZbiGFpkW2+EqKadJy1sGMi2Wj2ZWa6meA479K4w
CkDpYvRoCKNwaHL9rcgiM+rXpZd1Dch3qUSy8QUrXiYtWy8Slt8FlayLdPFfg21h
3FcJx7cmGrQM6sVxTSdO4oi09+nyRLK4z/FXslKjb6BdZPATtk8BB84Vcz3evt1a
e2Hqj3vQRRzk1NIer+ezW8efIoEE69mAUEa9Q7evu1u7CWH5MinBCF6koN2msebn
hCmfeBHn3DhKRH/PkvHIeTLgotrRuxK9A9ipjLtlcmS+VPtZ/s5imm/t4LunFPRU
r7WJ5S6MPf7e8w5uauhyRXN5p/KhYxb2TnDwia4nvv+W0IQoxYlhN17RWbqyJmXl
LAUwcuqVzU4omH8cBhK61+T9O0C0rM4QDccS8vR1ExGzVi8Gf18i0ff40BaN9+lr
sXxDirgtbeZaqH1r8d2nRXrZZxtMsq/bBZmdEGbCpvLGvOOa0mplmLJT/z7AABLk
1mO0pvMFzekaWQy83H9H
=Z06A
-----END PGP SIGNATURE-----

--=-1Bu5vT7Gu0BVNYdIBTam--
