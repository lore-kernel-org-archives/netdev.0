From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client
	MLME
Date: Thu, 04 May 2006 14:26:53 +0200
Message-ID: <1146745613.1137.28.camel@localhost>
References: <20060502211817.GA30842@instant802.com>
	 <20060503182815.1a9ebb5e@griffin.suse.cz>
	 <20060503164458.GB10524@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9R6kToviEJ3eeo1o6eup"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:27301 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932276AbWEDM1H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 08:27:07 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060503164458.GB10524@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9R6kToviEJ3eeo1o6eup
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-05-03 at 09:44 -0700, Jouni Malinen wrote:

> But there is.. I committed changes to the wpa_supplicant devel branch
> for this yesterday. It seems to work fine with net/d80211 and bcm43xx
> with this small patch to d80211 to allow the functionality to be moved
> into user space.

Cool, do you have a list of things that we need to support for it to
work on a 'softmac' based driver (iow removing softmac in favour of
this)?

> I have not yet heard of anyone working with details of converting the
> management frame communication to use netlink.

I have an interest in this, as soon as I can I'll try writing up
something.

johannes

--=-9R6kToviEJ3eeo1o6eup
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFnzCqVg1VMiehFYAQK5uw//btFpBhS+iQjRwwsm0A+CgxQS4XP4sxIL
WWZyJDRrMulU1pS5e9Ea/JUFS8evcGlCY/4ms6wsV2XUizW9IFeQRDw9OcyXjH6H
2y3wB5u8x6v9y5D1jlMgy8z4DlnxOUBEp0xFqcoCTRTzBpx4Zrue++XYe63K3bvH
NiJIEN1BCRypTnyCTChmNU9qYGZxpqNYxi/Bz9oDHcfId6BottA1e5Lpb8EybLOk
FfWrdfaWucnxrMbOnjsXizJw75m+1rzkpQ2TpuIAqgWW6Dh7JG4J/T5okMsJEK6M
rRSEMTg13NnJyptHFyKutKpfqfddSeuJD0dM8StcC777qP7LV9Fa6nOKK2+FBYoB
Z3QHQQSKiOcEEfwIa4DZwNi5F2MpXn0VY1JCS82kz7O36ydG8D/Ox1dSgkei+NSu
3vPjKVjUKpH30ds687jUht2NIqteTOxKLbOl2CDOtgLUO+NwdJTViZP+DNBoEknH
wI0ifc2Des6m7vc6U61bPkNEulknbdYJdBVBgdOpxNNvXC5LaybWuV1312jeLUF0
M8gY8JM3bRYxdC/luBAhbo9BboMztGhJG7HFBch7JIF6cesIpnMMC4HjgnMWA396
8ecquUJcUpm4HFMJpsrIFmeW9IgLr4yF2wC+qvrTryvWMU1I7WvTiai+jO3VEiDT
EIY4eU3n8zY=
=BDNH
-----END PGP SIGNATURE-----

--=-9R6kToviEJ3eeo1o6eup--

