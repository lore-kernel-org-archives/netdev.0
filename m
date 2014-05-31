From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: pull request net: batman-adv 20140527
Date: Sat, 31 May 2014 11:26:39 +0200
Message-ID: <5389A04F.1000500@meshcoding.com>
References: <1401157547-25199-1-git-send-email-antonio@meshcoding.com> <20140530.164757.984109840722396912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bU3jgRmxEIjtOMn6WxLpx02QkAWiFCCvF"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13294 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbaEaJ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 05:28:13 -0400
In-Reply-To: <20140530.164757.984109840722396912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bU3jgRmxEIjtOMn6WxLpx02QkAWiFCCvF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David,

On 31/05/14 01:47, David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Tue, 27 May 2014 04:25:46 +0200
>=20
>> Hello David,
>>
>> here you have another very small fix intended for net/linux-3.15.
>> It prevents some multicast functions from dereferencing a NULL pointer=
=2E
>> (Actually it was nothing more than a typ0)
>> I hope it is not too late for such a small patch.
>>
>>
>> Please pull or let me know of any problem
>  ...
>> are available in the git repository at:
>>
>>   git://git.open-mesh.org/linux-merge.git=20
>=20

ops, this was supposed to be:

git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

Can you pull this tag please?

(I just rebased my branch on top of the current net/master once again to
be sure that everything is in order).


Thanks a lot!



--=20
Antonio Quartulli


--bU3jgRmxEIjtOMn6WxLpx02QkAWiFCCvF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTiaBYAAoJEJgn97Bh2u9en0gP/31gmJwhZtQ6qScd7W7etRTb
3CmmBimjF7IbYDnrTWwukCcnOXtMZzfuOWmwUs7L2SP8QA2I0CqMkBb8UWD0M8mS
mkp0DJN4llU+BOxcK8aZy+hcO8zD1w/1p6tVhqUmPlgJnmu9P+lRk+ju/oH2r9B8
WMquc5rRwCoYTztx6DquUb160i9Nts1x66xw3LREzuCLynb4eGs94BccVpKbu7P/
8Bdvphf2aFvgRCqagu8cbWBjfku7XZJE+GAsWyDeeYlPpkUoFbwYHKnQwafHaeHw
jAARDSkG0HCJdpABWplnwxgDh4oKsruTkdvyv7WfoK9YCoO5Xn+SHISixP6l/ba6
h0Qu16WP3f4x5UitgRjWfFRBrqVPV7VbnpdsKt/e+7tNoAX/o3QkEGJSuD0qtjwa
wlTqmjpBniGzogd6Semkh+j9J4t3ulUjwzQMxiGy1qJr4uhSfAPjQ6L2N2y8s4x5
I3T8O++3/3iqkFrYcMlrgjOHK7ZImwGxAAFmOen6D2EFt1nyJq8jL8NAQyxyuDt2
/M7Zi3INcTy/lmAlbSwe8EU7Plm3cgpcMoFjbyN4beZcd/glEmiRFzMRxu23bIUy
d/49i6ek99pODDA7baomFFK1LAWbZaKs552AoI3zYRxPQx37ioU6JVqdzgZDMlfg
1TV3qU1hwThxoYk7VqwF
=mJJP
-----END PGP SIGNATURE-----

--bU3jgRmxEIjtOMn6WxLpx02QkAWiFCCvF--
