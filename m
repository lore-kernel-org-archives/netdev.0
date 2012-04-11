From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-04-11
Date: Wed, 11 Apr 2012 16:31:03 +0200
Message-ID: <20120411143102.GE19365@ritirata.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
	<20120411130301.GD19365@ritirata.org>
	<20120411.095809.861355939666821335.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jL2BoiuKMElzg3CS"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120411.095809.861355939666821335.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--jL2BoiuKMElzg3CS
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 11, 2012 at 09:58:09 -0400, David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Wed, 11 Apr 2012 15:03:03 +0200
>=20
> >   git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem
> >=20
> > for you to fetch changes up to 7a5cc24277b57ce38eb0afa6634b71d4d5cc671e:
> >=20
> >   batman-adv: add bridge loop avoidance compile option (2012-04-11 14:2=
9:00 +0200)
>=20
> Pulled, but I think the way you're doing the bridge loop avoidance stuff
> is wrong.
>=20
> Don't use a Kconfig option, use a sysctl to turn the behavior off or on
> at runtime instead.

Hello David and thank you for your feedback.

Actually we have either the Kconfig option (for binary size purposes) AND a
boolean attribute in our soft_interface sysfs path (to dynamically turn the
bridge loop avoidance ON and OFF as you were suggesting).

Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--jL2BoiuKMElzg3CS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPhZWmAAoJEFMQTLzJFOZF87sIAIr01pg8kTOytH7uYWkEcTNN
TK6PtHcytjgeau3PjOduyAeLnyLxV5HK0GE7z6ua4kUCPFEiahqtfGB8tFlB/pWp
GYuqnyG1XQ8Vxtgm6OYaudJ6R6hh4/ARgBIw8sRvL785IL9WnnJhughEWFQuG7QU
THn2toKreXEZI7ZDRUrI+PV/S3Kfagjd7ikotFF8O/SPrFCa2D8BJLp6IDaMBaVm
UeO1KEFbpy1258RroBUM61Opq/6p09QOddKVW3X5SE6OWbHcMmKfq4lAqTK1PEDs
spVAnKzQiMVU/wBFwL3zOor+httNV3TBUVz24cl3ZmrgQKPg8/rYsnsUyrWsxJ4=
=1Fbu
-----END PGP SIGNATURE-----

--jL2BoiuKMElzg3CS--
