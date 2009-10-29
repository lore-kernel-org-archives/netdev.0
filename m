From: Antti =?ISO-8859-1?Q?Kaijanm=E4ki?= <antti.kaijanmaki@nomovok.com>
Subject: Re: [PATCH] hso: fix debug routines
Date: Thu, 29 Oct 2009 08:57:47 +0200
Message-ID: <1256799467.6514.5.camel@nomovok.homedomain>
References: <1256200578.3057.113.camel@nomovok.homedomain>
	 <20091026171550.GA24910@kroah.com>
	 <1256585855.3591.52.camel@nomovok.homedomain>
	 <20091026194058.GA25263@kroah.com>
	 <1256653615.3591.113.camel@nomovok.homedomain>
	 <20091028161617.26a58618.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-nHmyydPBcjshbCYQRMJu"
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jan Dumon <j.dumon@option.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nomovok.com ([83.150.122.238]:42430 "EHLO mail.nomovok.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451AbZJ2G5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 02:57:55 -0400
In-Reply-To: <20091028161617.26a58618.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nHmyydPBcjshbCYQRMJu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-10-28 at 16:16 -0700, Andrew Morton wrote:
> This patch has no changelog, and I'm not seeing any description of what
> it fixes and how it fixes it up-thread.

The patch fixes debug routines of the hso driver. Debug has to be
enabled manually with a #define so this patch has 0 impact by default.

Broken down from original patch:
http://bugzilla.kernel.org/show_bug.cgi?id=3D14469
http://lkml.org/lkml/2009/10/22/37


 -- Antti



--=-nHmyydPBcjshbCYQRMJu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkrpPOYACgkQJ/yWUtJ8RGp+AgCaAn3+ACkVCwrRKWEhDHsJ0XTW
9CIAoKm13gl36RoNt8VaXr4NdM6osz81
=CrgW
-----END PGP SIGNATURE-----

--=-nHmyydPBcjshbCYQRMJu--

