From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me comment in
 the function,gb_acquire_swfw_sync_i210
Date: Mon, 09 Feb 2015 00:32:02 -0800
Message-ID: <1423470722.27854.11.camel@jtkirshe-mobl>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
	 <1423444889.2589.165.camel@jtkirshe-mobl> <54D85EFA.3020501@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HxhS78M6Vx5JGcLCROjv"
Cc: Nicholas Krause <xerofoify@gmail.com>, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrej Manduch <amanduch@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D85EFA.3020501@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HxhS78M6Vx5JGcLCROjv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-02-09 at 02:17 -0500, Andrej Manduch wrote:
> Hi,
>=20
> Can you please leave full patch with git diff when you're replying to
> Nicks e-mails? Nick is banned in *@vger.kernel.org so we cannot see his
> patches and rest of the world is seeing only replyies to his e-mail. And
> it's really hard to test anything when we don't see changes.

Oh, I am well aware of Nick's current ban on @vger,kernel.org mailing
lists.  If you want to see Nick's patch, feel free to view his patch on
my queue tree:
https://git.kernel.org/cgit/linux/kernel/git/jkirsher/queue.git/

It is the top most patch (i.e. last one applied to my queue).

>=20
> On 02/08/2015 08:21 PM, Jeff Kirsher wrote:
> > On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
> >> Removes the outdated fix me comment in the
> >> function,gb_acquire_swfw_sync_i210
> >> for setting the variables, i and timeout to the intended correct
> >> values for
> >> the function,gb_acquire_swfw_sync_i210 to function correctly. This
> >> comment is
> >> no longer due to these values having been no changed in the last few
> >> years and
> >> no known issues have been found for these variables being set to their
> >> current
> >> values. Due to this the comment can now be removed as the values set
> >> for these
> >> variables are known to be correct after years of no known issues or
> >> bugs related
> >> to their current values.
> >>
> >> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> >> ---
> >>  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > Thank Nick, I will add your patch to my queue.
> >=20
>=20



--=-HxhS78M6Vx5JGcLCROjv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2HCCAAoJEOVv75VaS+3O0iwP/jpx/ps8NZ4U8mB2O36O8fcS
oM2MgTW+HXPM66eD0yke+rK0x5UfxasvZgVXh0NkdtRJrgYYqf7bybaKRRxzEfbP
kAqYrJDQsxERqYsb3ExY0yTivI7ydzpZwhi94Kq7l+v3OIdTS4SBzA3pyRp5zaeS
nbhLRBdKbBpzVlTmqosN6aj8+X4KEsClCyCt/yqnWI3UpkGo/qe+7PAgtNheq4C2
obVXf9mi6YEQrcYpliHaWtLcxkNlb7iI2lfAWvDUVeot7PIKQWBbJOFFeyMK/s/A
lgp+jqwws3CAJpbDUJBUcPrhAtuJYK2+Yz307vQyw7ee0ilVAqHyIuo6+gHiX09L
jlUfSjdpqYuV5L+2s2bjC3zEhpj3TrMVZmMjLGVNX/Kys+7Fj/vd/XG8QKnS7c5i
+uBIpibHu4swcZ2KBTb1hGdHEHt6azVi5gKY6v72dQBRVh1gykXUFNct5fifO+eI
lcxzn1pPq6LKifOrs2AdR76ITl7U6XN9eS3l9pZWqMv0yfePGqKKQhDyCw4brZcU
2e9EZM51ii+n+MFVEp4OcqHRnlzkFRqgm89OU3pr1k/Cf6xZjkfCwAFC05jUJPan
dEw2gXYCgnrgm+HYnZ7DfEclG543IKkqKn3btVuP+H15sfQeCueNI97ImT1kzF9H
3buXFcjVrzk0rNkZSZfs
=wYfd
-----END PGP SIGNATURE-----

--=-HxhS78M6Vx5JGcLCROjv--
