From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [Prism54-users] Open hardware wireless cards
Date: Wed, 5 Jan 2005 16:53:30 -0500
Message-ID: <200501051653.41053.flamingice@sourmilk.net>
References: <20050105200526.GL5159@ruslug.rutgers.edu> <Pine.LNX.4.61.0501052017380.5818@rivendell.nexusuk.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1788797.UstzDMJBSy";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.61.0501052017380.5818@rivendell.nexusuk.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1788797.UstzDMJBSy
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 05 January 2005 3:22 pm, Steve Hill wrote:
> On Wed, 5 Jan 2005, Luis R. Rodriguez wrote:
> > What I think we probably will have to do is just work torwards seeing if
> > we can come up with our own open wireless hardware. I know there was
> > a recent thread on lkml about an open video card -- anyone know where
> > that ended up?
>
> This may be a silly point, but there *was* good 802.11g hardware available
> which worked well with the fully open drivers.  I presume the
> manufacturers are moving to the "softmac" design instead because (for
> them) it is cheaper.  However, the point is that the working designs are
> already there and it may be that buying the existing design which is being
> phased out is cheaper for the FOSS community than developing a whole new
> open device.

Softmac doesn't necessary mean evil all the time. The adm8211 has a fully G=
PL=20
driver for Linux. There is no firmware to worry about either. ADMtek actual=
ly=20
helped me with the driver, by providing the source to their old 2.4 binary=
=20
Linux driver and sending me (from Taiwan to New Jersey, fedexed overnight)=
=20
two sample cards to test with. Oh yes, and it's quite cheap. (but 802.11b,=
=20
which maybe a problem for some people)

If ADMtek can do it, why can't other manufacturers?

=2DMichael Wu

--nextPart1788797.UstzDMJBSy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB3GHlyWWBbDEe0UIRAv60AJ4r2kU8cLsPl+Hu1OGKu+6GTaAqegCgvKfh
ogmmOEs5Gv4d17bomnelBzE=
=2oNQ
-----END PGP SIGNATURE-----

--nextPart1788797.UstzDMJBSy--
