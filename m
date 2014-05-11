From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] pull request net: batman-adv 20140510
Date: Sun, 11 May 2014 09:16:47 +0200
Message-ID: <536F23DF.7000807@meshcoding.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com> <536E4882.4020106@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc
	   Networking <b.a.t.m.a.n@lists.open-mesh.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="nDqBw1I94sRvKh2IvR65Ds0QLAambrauU"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:16632 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaEKHRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 03:17:51 -0400
In-Reply-To: <536E4882.4020106@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nDqBw1I94sRvKh2IvR65Ds0QLAambrauU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/05/14 17:40, Antonio Quartulli wrote:
> On 10/05/14 17:35, Antonio Quartulli wrote:
>> The following changes since commit 1448eb566970c6d3cade522419848fdaee2=
4c684:
>>
>>   Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/linville/wireless (2014-05-09 16:46:53 -0400)
>>
>> are available in the git repository at:
>>
>>
>>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-dave=
m
>>
>> for you to fetch changes up to 29bcc8064fc0b82bc708c09577d550923b954e5=
a:
>=20
> The tag points now to 05191f523653461ca6a4e4fb38012e0d8f3c5641 because =
I
> fixed a too long line.
>=20

David,

the batman-adv-fix-for-davem tag now points to
709de13f0c532fe9c468c094aff069a725ed57fe which contains the fix for the
long line I said before, the fix for the kerneldoc as suggested by
Sergei and a correction of a small typ0.


I can re-send the whole pull request if you want, but I wanted to avoid
to create more noise, unless it is needed.

Thanks a lot.


Cheers,

--=20
Antonio Quartulli


--nDqBw1I94sRvKh2IvR65Ds0QLAambrauU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTbyPkAAoJEEKTMo6mOh1VrRcP/AxiLNfcvEZcP3Uqw4XNGvTj
5SwKDKc/tu8ON8OEFXUQkJKf/VFmggHQb3nRL+NZu1+9ubTET5FhfmpwryCQiyjY
lFI5Zrh6iy28kSFjE9haxDNshT1QkuufjTZo05E3UT7aCgTw/8kC5BSec3ViBRsL
XZ5pt+QixI2/k/Q8z7uPv3I8I+oHvSTu12ciyJZyGA1G+dvwrF6QsuIVPWIch2YH
2OJXVTrTK6E5pIHyu/rGHVAZZQep5wVx/CoaLBbyQKR4iPh88UD5WIwplQvRkU/W
sZ4xtp47R1nP7v0xkHLbJykshfxXmUWBpWWdrU4A6HvBBRZrykielrxkVNgdlKLR
Ksrrs+7eP6TBut7VkOLMQmqmvoUloZX20ES6Dc6bzUOYt/AEoXGIBDMFtFqdbNgL
YYNH8C+P3u7jzK0IA3PJ+vjacEWhPDPw09QMlQDJ/JxAqb8dd9uO1ai2HxOhvMw3
CS53i1AvzvYTJinaiJ/Z3kdrmewf+scX2CyAzsskU+Fc9fLVmIpJWeWf9eGIKYQp
YdO0KzaeJ1ldIVgaNcwsJ+cMd8zUnjwWfCAB4tPu2Z3WRm5Y+rXRm/s7YvoXg1QY
zFJIlEytkhLVRMQaxNfa/1TMt9FCGyuCSUNmMo+vFoI4TFsaHwET3Enb/2P5K0Oi
ddM5IPUchUSkTwlgNIVZ
=rAfC
-----END PGP SIGNATURE-----

--nDqBw1I94sRvKh2IvR65Ds0QLAambrauU--
