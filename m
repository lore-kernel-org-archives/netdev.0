From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [net] Intel Wired LAN Driver Updates
Date: Tue, 31 Mar 2015 21:27:53 -0700
Message-ID: <1427862473.20936.5.camel@jtkirshe-mobl>
References: <1427497451-23642-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20150331.132214.1693397186943204005.davem@davemloft.net>
	 <1427854793.20936.4.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KSLVG8xING78aY25KLKP"
Cc: nhorman@redhat.com, jogreene@redhat.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427854793.20936.4.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KSLVG8xING78aY25KLKP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-31 at 19:19 -0700, Jeff Kirsher wrote:
> On Tue, 2015-03-31 at 13:22 -0400, David Miller wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Fri, 27 Mar 2015 16:04:10 -0700
> >=20
> > > The following are changes since commit
> > dde93dfea53c72b07907d9e44a6e4b1545f6bdc4:
> > >   cxgb4: Fix frame size warning for 32 bit arch
> > > and are available in the git repository at:
> > >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
> > master
> > >=20
> > > Jeff Kirsher (1):
> > >   MAINTAINERS: Update Intel Wired Ethernet Driver info
> >=20
> > Looks great but it looks like nothing is pushed there?
> >=20
> > [davem@localhost net]$ git pull
> > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
> > master
> > From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue
> >  * branch            master     -> FETCH_HEAD
> > Already up-to-date.
> > [davem@localhost net]$
>=20
> Sorry, I forgot to scrub the cover letter to remove the "pull" info,
> since it was a single patch, I did not think it would require a
> "pull". :-)
>=20
> I can apply it to my net-queue tree, master branch if you need or want.

I have gone ahead and pushed the patch to my net-queue tree for you to
pull.

--=-KSLVG8xING78aY25KLKP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVG3PJAAoJEOVv75VaS+3OTLUP/iUBFDlwyboTqWHjmt/Lyj9u
YFnmkUMVix12DcgqaL2ezefbD/3jEVVIyMhyfaaa3tErk8Plvv37vUOCUcA2GYo+
VKqWOaJkJEAgiUjvRa17gGMfkncuX75l4XxqpcQpb3upr4fTZcgUOWH/2Q6qp+nO
on3GgA6XrOnaGSPm0UEOEnrjCfHvNmjKV1Z2ZU8Uh5adpCYFQdfFbMxO6XrHVFGY
QGJmKe+efoEHmaBLP6Hf/hV+Xn6stzV7wjD87GAhPE92gT2RRVLIzwStY+M/tHCe
FCVVNb8bQgw5kdcZ5Wlz3xC+eZLaHlbCr5UTrkR4ZJkNO2M7cf2joqW7PXHAkMru
d70meM/NDL0o+CMor5wI2JiBsUZ206AHnMW9Te3LF7+0sbVAJ+PhPW+ccWZOn8ln
UhBqPXWsslH3wJLyy/k4zRfr359p4NpkHQQQJfwzMKEiGbSmAHjncrhn+uWnFGCr
Gp9fJ0Kdsm4b/LDagHQkMft4UvQqYfQI5Y13Do9dkFIEkPhTpkjWwYjo88YJ9F0B
wWaA83GPnju2NVI5zWfwf/gXKFT6DMuaAzA2rC8Z0kJ83usaopoN/8nbFXjCErJD
roWkOQiOtklQRhElRps65XpM/UFlrNgRZ3u4/7DpQ9mIJKpzCVhDU0mVGZBkis/l
BRxEk2vb3ExviSXkk3ab
=CZC6
-----END PGP SIGNATURE-----

--=-KSLVG8xING78aY25KLKP--
