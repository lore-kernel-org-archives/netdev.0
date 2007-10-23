From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/5] Diet struct net_device a bit
Date: Tue, 23 Oct 2007 19:07:12 +0200
Message-ID: <1193159232.7733.24.camel@johannes.berg>
References: <471C9830.5070407@openvz.org>
	 (sfid-20071022_133116_617054_8D3C9D5D)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-E93tH6xwXUde8v4OBhRQ"
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48430 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbXJXIgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 04:36:40 -0400
In-Reply-To: <471C9830.5070407@openvz.org> (sfid-20071022_133116_617054_8D3C9D5D)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-E93tH6xwXUde8v4OBhRQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-10-22 at 16:31 +0400, Pavel Emelyanov wrote:

>  * ieee80211_ptr is used in many wireless drivers. Need time
>    to check for the config dependencies.

Depending on CFG80211 should be fine, if not that's a bug elsewhere.

johannes

--=-E93tH6xwXUde8v4OBhRQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARx4qP6Vg1VMiehFYAQKfrg/9EoRyoTa/K3SGlcg7uRLn5+csOvEEmdyQ
1tDeu73xEtlVXk4NtJQ9V/n6Z5AOWKovmB/F7n+a+2d9/fs9IfRQIIgPlZ1ouH/e
yNLzyUVZYKwF1PK77wk8mSiTlnrDFnL/iTDx4KJSE7oTmoT3ceDeFvb6NlTtepdO
lAkOv7wEf3Hc7GP4FMZ//qq44PKtVF7sYbdsVDooINa7hYk2fs87fViLFEicqyZL
OtWftNcJ29Ko9ql0yRUH9MsUdpWImUg25oRVE2ZX9J9LsPu489T1qG3qABf1le7N
sKl6NykouGe4S0sFSaNlFp2aPVETe+gLKssugey1CAO7RhJm0a5h99u88cmZzryF
8yLD8DOrc6sOnKDQ5mqcpcmTiSj+OpxoY0nqVrtbVrVHhISE/I0o19OvMlGKajtz
PV8yFnJ8nE2MsPU6hLksWiI7lQ71X+jS/Am0TTRtML6mYIGsp6jHHa71Id4Iu8HS
51OPNpUjlf3HrohqQFxQ2phB7MI3F9MPGWP6XZuOyGvHApPHcELYkqHjwpCywsBb
9lUGHbZfjPi2J2+3KvUwqQINTuKYid65xxG5jFylTtA58bal4igdG1wt8ugZN9la
je4LhdT7zBaXkdRbNL55fDR2AHP2an3EGzYF4ySrDcBQt19pCEBTtj9fWR/MtB5c
ciUNWz6qKCo=
=tfC+
-----END PGP SIGNATURE-----

--=-E93tH6xwXUde8v4OBhRQ--

