From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 15/17] fm10k: fix possible null pointer deref after
 kcalloc
Date: Thu, 21 Apr 2016 12:48:20 -0700
Message-ID: <1461268100.3018.5.camel@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
	 <02874ECE860811409154E81DA85FBB5857A7C1E0@ORSMSX115.amr.corp.intel.com>
	 <20160421.154727.1143899173479860095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BO9UfKk0bMkZayllXWLD"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: David Miller <davem@davemloft.net>, jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62158 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279AbcDUTsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 15:48:24 -0400
In-Reply-To: <20160421.154727.1143899173479860095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BO9UfKk0bMkZayllXWLD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-21 at 15:47 -0400, David Miller wrote:
> From: "Keller, Jacob E" <jacob.e.keller@intel.com>
> Date: Thu, 21 Apr 2016 19:44:24 +0000
>=20
> > Dave, please don't pull this patch. Krishneil found an issue with
> > this patch, and I sent a corrected fix to squash in but it didn't
> > make it into this one. I'd like to get the fix squashed in a resend
> > before this is pulled into net-next.
>=20
> Too late, it's already in my tree.

I will address Jakes concerns in my next fm10k pull request.
--=-BO9UfKk0bMkZayllXWLD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXGS6EAAoJEOVv75VaS+3OnF8QAKAguORDwA455Y83gxOfWF3u
vuraIGdSwcb0YqHuUNzOKVe+s6w8KhMSzbJq4K+qIq4sv5u8yqxZiMNSoheUZAnj
KE3riuE5ir0pM6M28dPUiarxM9o449jUscKzxL9nzey7E8FyMDilmEqQjGWmCSiW
kO7RxFYtTkI0cTYhGltoTvLEvsoc7x4XPe7vz0RaNbcuGqdl8yT0qQgTEzVwPWbi
pMLVVPEmBRLlbExRWaJVy/xggMBhDIDjilvmOMutKVl8ZyDvBOKDJPiu51XXcrXX
nmamlHNlStJQ6kiihnlDuxpmG+MeeK5Pp7n+CVl6UulQjXoAWBpMxzmz6PW7igIt
mZxpTqcsFjL4dKT4Y+BOVWrAzlkR/HxxcNQ3gtuMcTqPsgybaYYipxlhuBBMxeUp
nVXTPQGo0eyu9MEt7AT/1NzeE8YJF8JlVNZ9o2pgVGRefRmA85vCvdhjPfnTsW1k
7pUdByrsmZ+zoYqnbEnKJS5uhDVytB1QX1n9F0gHKf+YZRtvMapgAKRfxKb3h08r
sA61J39mNYZQS45+hs+gW4cmm2SHE+KdSUI4S+5k99a1IhNamsB6ggrQQYbrWbk+
CVEwITmhhlSMO1h6XzjgiCXzTp+HuGedlynapRpSj1TArIJYXZyhIz9u6jjNHJK9
LHwdluxdGc99qEzeHsmZ
=nIbU
-----END PGP SIGNATURE-----

--=-BO9UfKk0bMkZayllXWLD--
