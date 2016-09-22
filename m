From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Thu, 22 Sep 2016 16:32:18 +0300
Message-ID: <20160922133218.GF4088@leon.nu>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
 <20160920163048.GQ26673@leon.nu>
 <SN1PR07MB2207C1EC2C5C86C607D0255AF8F60@SN1PR07MB2207.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="/aVve/J9H4Wl5yVO"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Borundia, Rajesh" <Rajesh.Borundia@cavium.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Amrani, Ram" <Ram.Amrani@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:36046 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752275AbcIVNc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 09:32:28 -0400
Content-Disposition: inline
In-Reply-To: <SN1PR07MB2207C1EC2C5C86C607D0255AF8F60@SN1PR07MB2207.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/aVve/J9H4Wl5yVO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 21, 2016 at 02:15:39PM +0000, Amrani, Ram wrote:
> > >  include/uapi/rdma/providers/qedr-abi.h     |   35 +
> >
> > Please be aware that the last version for ABI header files doesn't have "provider"
> > name in directory path (include/uapi/rdma/qedr-abi.h)
>
> OK. Note that I was using https://www.spinics.net/lists/linux-rdma/msg40414.html that dates to 7 days ago and it contains the "providers" folder.
> Can you point to the most recent patch?

http://marc.info/?l=linux-rdma&m=147419583317034&w=2

I'll post new version soon. It will add mthca driver to the list of
moved drivers.

--/aVve/J9H4Wl5yVO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX491iAAoJEORje4g2clinPfYP/RBg6gjMwZ9xwvsi9fpK/HlQ
OycSDuFXhOXxkKE8bJAI3xKiydUiiwXG4qIkOgrPT4FPxQRxIxpG8K3Gu3fYuo3U
GYmPW1x6iy5mnbd6oS30Xex/lLdar5B0YgKstRo+LhFjXtb3xYo1smKsHuHb0pXg
KOUbZ7UyCESuxAoH9W5UjEkWxma9Hdk6tbkwIOkcMTSLn5TuTqn1o7Iym4vAD6zb
FRobZ3iqw+g8sWEFVEQq03H3nqkY6w5G2KQfB2ZLvq/t6EttMdfGvHnPyj2z3M0X
2h0t7uNmyDcqQ9mFj7yIvYLa3iY6OopGG1r4Cyt3FiyxoSuV9zTOETM9VG5TP6rX
90y6kGZNzdDn4/M+rAw4zFiWv4Nca6++9GYuhBXZM2LSJxfW5kc/dZExjZNAdQhc
6KwxeJAViI2xRUj8ps1PwxZXKhRAi9AgghZCc6933no8eyY83mJGOEwAL6XSn8IB
4I8ncjxyX040XCqTVX1/WwfmXYw9OfAifHPKN4a0Re1hS4lmV03xZRGUdjMzs+uj
5djzieh1cBcGGD7q0rXvUN1blDvu7tNjRCC1OSmBISXGcE17PCG3A0IxpSkVDee5
HQfCoo+pnD1UM51faJSdeiPFjHXBay4fzP//sY/MKeQjquixjEM1/PVm3xhMjg/Z
j6c1cql0mfGLicjN1rYD
=xUkQ
-----END PGP SIGNATURE-----

--/aVve/J9H4Wl5yVO--
