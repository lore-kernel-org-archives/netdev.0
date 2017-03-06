From: Felipe Balbi <balbi@kernel.org>
Subject: Re: [PATCH v3 17/20] usb: gadget: pch_udc: Replace PCI pool old API
Date: Mon, 06 Mar 2017 16:46:32 +0200
Message-ID: <877f4231kn.fsf@linux.intel.com>
References: <20170226192425.13098-1-romain.perier@collabora.com> <20170226192425.13098-18-romain.perier@collabora.com> <20170227111916.GH26544@collabora.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Peter Senna Tschudin <peter.senna@collabora.com>,
        Romain Perier <romain.perier@collabora.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:25801 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754279AbdCFOrx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 09:47:53 -0500
In-Reply-To: <20170227111916.GH26544@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Peter Senna Tschudin <peter.senna@collabora.com> writes:
> On Sun, Feb 26, 2017 at 08:24:22PM +0100, Romain Perier wrote:
>> The PCI pool API is deprecated. This commits replaces the PCI pool old
>> API by the appropriated function with the DMA pool API.
>>=20
> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>

Fine by me:

Acked-by: Felipe Balbi <felipe.balbi@linux.intel.com>

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEElLzh7wn96CXwjh2IzL64meEamQYFAli9dkgACgkQzL64meEa
mQaVLA/+IjA1+ooZeFlRFue4K18JSOEfgED6F5lc5rGYp4MSCvuqECFs6Xm1dfpR
Ifbq7IfJF+ATQ/zIP0xASPM+qjWc3Nx+61gsHhfNbefZWYwWrgkj+5eCIcVhCXQo
Tx2Y97j5QwNcLd5+TDfdtpm2NkgeiM8M+/HcoV4a8oLHxItlTrfsvVyxGMGVe/Hj
AZ1WLJRoZVTwrfAnzr6JHdB8g+2AUeeSMSH8i0r0ZMU0BlcE5s7kste7tsPZyhRe
hkVdGJPWdh+p42GxPoHCEZ8DI06cunrPq1iRX4qtPCrytGUfp5Rvz0T4svXGyL1X
MYaAxTRPvkbgsw7cvQ6M0MWW+8j3IJkTF6wRKTVU0hRsPR/KjePXwIxYS81gbxwj
m4BlfmfN7N9ahfEjcwCqqOKv8CwwtNBh7EsTErIcBuvFM1V2FQm7C6avU+u9bX3e
nL2G5V55sbKDV99U+MLxe7d2j/sFo2p1uhMFH1GxkB37IF7IWZ4IIKz/NhSOfiqf
YOKmyE9nB9DeuloF3KgOwAV5pSIzF2RGaixCpgZ/WKH4yPm+zz3cKciQLKtIE0BT
hLX8G7oeyV8E7FNEugDzDooAX4YX8WWHaNeWwqIhW3spnQNnPavYvkq0n0MDT5lQ
cUjg7idn7kP0l3YG86Sb6vfwDQGyEUxd3iFZ0HkSMlOUUA90izg=
=BoeH
-----END PGP SIGNATURE-----
--=-=-=--
