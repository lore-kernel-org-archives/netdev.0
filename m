From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [net 1/6] ipv4/ipv6: Fix FSF address in file headers
Date: Thu, 12 Dec 2013 08:56:01 +0100
Message-ID: <52A96C11.5070508@meshcoding.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com> <20131206.123855.1262992770410595267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="TnP5slXkRrubRaGlEaNGqoolA8xlcviSH"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21563 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3LLH5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 02:57:18 -0500
In-Reply-To: <20131206.123855.1262992770410595267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TnP5slXkRrubRaGlEaNGqoolA8xlcviSH
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/12/13 18:38, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri,  6 Dec 2013 09:13:39 -0800
>=20
>> Several files refer to an old address for the Free Software Foundation=

>> in the file header comment.  Resolve by replacing the address with
>> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
>> updating the header comments anytime the address changes.
>>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Applied.

By using this approach we make checkpatch unhappy again.
What do we do? We forget about checkpatch?

to follow checkpatch's suggestion we should remove from "You should
have..." on.


Cheers,


--=20
Antonio Quartulli


--TnP5slXkRrubRaGlEaNGqoolA8xlcviSH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSqWwVAAoJEEKTMo6mOh1V4uUP/0a7f17n/q9dZiEazhND6s05
unf0zlnE/TpuQTcuhQ/JI9SNS7whQRwJYY91wZFTVu/7dFItbZRC3I2R8vAen97I
2YhnFG1dPF0BL/M6YCCMa4r7MvtLiSAHkiYK8rlA8vBAWUDQsu3ICICp87O1/qlu
9Zbt9v+AX6eQp1+yMWbOLdIZYcj6KH4w3b7kpEWOBdME2S7ebsIDzJ4a/pzZRoH0
PBNaGqEo5Kv6uQzBUnnXV0AdRqcKjc1Vby7sEVZL1rpo0N0vSE+qglc8HviTpMJq
qSY1ABX7AG4q7hbEnP/5WkzWV4gZSVOqo/6+QT9hf1uYx/VXxkc0a8Gqkt4o3Y/V
b7WGGObZbh35MTMhxbnCkykiNSaI2okTxgbhL2wc5l2Z6E2p6UEBnS55IDJZ2GVg
O2mm5juK4nvAo7clV6+FZjWQ847IZ0hltbQpbfIbXT55bmMZrlWJIhqQFHqGspkJ
SOpo7lgMt0QDHqd4823RRO3RkxKZlJaR9UUiMrt7T00BTDvzTrtoK4nIagf1f/JG
Nty1UFkFMHkH2w8y/NL7yIYrXwlhMeIVet1gJD1VL8SNdT7N+Li2VtOyReuoByQX
Y+8l3F3Hmo8k9523y2tl+SSyhPIc4aVySgkaY1dVbkAIqOf6PV4hSLbLemA1zNiR
+W3Ahn+DCjhNl52tVjU1
=l4q5
-----END PGP SIGNATURE-----

--TnP5slXkRrubRaGlEaNGqoolA8xlcviSH--
