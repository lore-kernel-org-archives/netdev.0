From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
 2013.01.27
Date: Sun, 27 Jan 2013 19:00:14 -0800
Message-ID: <1359342014.2255.59.camel@jtkirshe-mobl>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130127.190748.404517979856325333.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-N8F/n6zGoS8BMIThW84n"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10881 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab3A1DAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 22:00:17 -0500
In-Reply-To: <20130127.190748.404517979856325333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-N8F/n6zGoS8BMIThW84n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-01-27 at 19:07 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 27 Jan 2013 02:39:39 -0800
>=20
> > This series contains updates to e1000e only.  All the updates come
> > from Bruce Allan and most of the patch fix or enable features on
> > i217/i218.  Most notably is patch 03 "e1000e: add support for IEEE-1588
> > PTP", which is v2 of the patch based on feedback from Stephen Hemminger=
.
> >=20
> > Also patch 04 "e1000e: enable ECC on I217/I218 to catch packet buffer
> > memory errors" should be queued up for stable (as well as net) trees, b=
ut
> > the patch does not apply cleanly to either of those trees currently.
> > So I will work with Bruce to provide a version of the patch which will
> > apply cleanly to net (and stable) and we can queue it up at that point
> > for stable 3.5 tree.
> >=20
> > The remaining patches are general cleanups of the code.
>=20
> Thanks, please provide more commentary like this in future
> pull requests, it helps me a lot and it does get added to the
> merge commit I make when I pull from your tree.

Your right, I have been neglectful in doing this and will be more
verbose in future pull requests.  Thanks Dave!

>=20
> >=20
> > The following are changes since commit 031554eab078705edb96e9a39665597e=
3fd22781:
> >   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/jkirsher/net-next
> > and are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r
>=20
> Pulled, thanks Jeff.



--=-N8F/n6zGoS8BMIThW84n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRBem+AAoJEOVv75VaS+3Oq5wQAJHaAdIU29tPGVNgvKd3PEf9
TvrV2qwAIHVKvJSWdqAJFsUi1lIew2HlL4PWxMnXc9Uv6RacroiozwS1t5ESu8BC
QrVQgY7de1tZPKFWVp1PGkjKu+mnZtKaAqwseKeCpD/SBFgfhsSIuXZpWOUEVBh9
6UD+hBHDndeK8Q0xzAXfhniqsnOSCOeI8XWavfFVW0/q5to5324iHv9a4zLfGkad
cB37p1SnMY7mJmBYNfWZi/I2R1ckaAj/WqE0da13aNvb0SRdqy0CvwJrksiMxbzk
Li8GpWu5HF+uLziaeK0kQCNc1xh3kALV9p38aTS7TJ/6cgXLXN2a9QbSsfzDZuUP
VrWAezxeoZXWPvGFf77bGY3fwIkhuOUj3Z5x/uFdqqJgdgRObxZS+m3H6sLODyBJ
pIgH1N+k1ONY4bZnXbA2x38Q0C0ScQNKvgFIrKqiGmcaXintU6CoeKHOwN2xkb+E
59SLgdGMybIR4xrhdCBVVF+KH9Q0N3q315Xjz0qdJU0yOAWZZcLuZY212xTW3elk
5WtyPLTqvjglxyyIeHkNjiv6JaNSQYtY05H/V7BkcIovfTWldcpIRp7kz5smtKcu
z9X2YxW2vLfYnnpfoq5y1e28Y8cnWPd3gKmSzgjUwY+Pv5vRlIADKkMnXVwGyBri
yICHxdGOzdYsmuLVbotG
=pumd
-----END PGP SIGNATURE-----

--=-N8F/n6zGoS8BMIThW84n--
