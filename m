From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net  8/8] i40e: include i40e in kernel proper
Date: Wed, 11 Sep 2013 08:37:30 -0700
Message-ID: <1378913850.2026.19.camel@jtkirshe-mobl>
References: <1378893056-4821-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378893056-4821-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378902002.606.42.camel@joe-AO722>
	 <1378913071.3863.27.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-22y8MZ4vhl30CstBS1j6"
Cc: Joe Perches <joe@perches.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34165 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754802Ab3IKPhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 11:37:36 -0400
In-Reply-To: <1378913071.3863.27.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-22y8MZ4vhl30CstBS1j6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-09-11 at 08:24 -0700, Waskiewicz Jr, Peter P wrote:
> On Wed, 2013-09-11 at 05:20 -0700, Joe Perches wrote:
> > On Wed, 2013-09-11 at 02:50 -0700, Jeff Kirsher wrote:
> > > New driver build option is CONFIG_I40E
> >=20
> > > diff --git a/Documentation/networking/00-INDEX b/Documentation/networ=
king/00-INDEX
> > []
> > > +i40e.txt
> > > +	- README for the Intel Ethernet Controller XL710 Driver (i40e).
> >=20
> > Just curious but why the XL710 / i40e name mismatch?
>=20
> ixgbe is a good example.  ixgbe is the driver name, but it supports the
> 82598, 82599 / X520, and X540 chips.
>=20

Another good example is e100, e1000, e1000e, and igb. :-)

--=-22y8MZ4vhl30CstBS1j6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSMI46AAoJEOVv75VaS+3O390P/i2E2Yc0X0o2NP4dqOb0PBSh
1nAcsA1HhLp4m8pyKVBtVqb0u3kt5bOF0OqkON39qrNTXMsr3KnWmDAt4CqV38tX
VRac1UGRFpY8Imap7IjtDWZH7FNXfWKyTx4a8qns7zYA6cYYFSl+ItG9JMmGtd+z
4XAEetUou8Erzwn9sr1ktVxjnC3P5E+EWBBwhYwMu628ivGprMn7KqgwVGwcd9oq
0ouYQ5iUaIPTW/jD9DfkB5DOZKD9Y8ydT9Ln2PBlUKwbvPKEjHKBOSo+d/6IwaNF
IxGv6pv4+aR/21WW47E7zh763n6jaVfJiaVsO19lzaTYL16cOAtbe4WAOR7l6IUc
RJGImCuK/WKZ5Dq+kb69sBgvq/x+4ZbVLfMjwPw0ccd0c6NUpYLiJLFVgLYtZotj
eAxTMGjGGUabwLxg65YvZP0b9S/qa8hPYHGTs387khxYHBKo/6RYHGFFvgdjGYAQ
TgG7oxvdmFqd1W/i8ZfdAL+t6SwZmMlCi+s6QsgfdDafLPXjfbrzSRBTOP9H63vy
fgKGQkMHhvBC2Su6DlAAGL+ZZw/f8Uzvaw/QJoSE1nPAbCD2N1frXI1XXrUjcYrp
MFTFmODpMkMZA5LFZDDhrjTCsP4G0mu6q0P17uTUkrItzfY+uRtFztfxg0KIk1/H
UzwHkgWwehVDY82qirl6
=6P9e
-----END PGP SIGNATURE-----

--=-22y8MZ4vhl30CstBS1j6--
