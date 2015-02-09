From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] net:ethernet:intel:Remove outdated fix me
 comment in the function, gb_acquire_swfw_sync_i210
Date: Sun, 08 Feb 2015 17:29:19 -0800
Message-ID: <1423445359.2589.171.camel@jtkirshe-mobl>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
		 <1423444889.2589.165.camel@jtkirshe-mobl>
	 <1423445167.2589.167.camel@jtkirshe-mobl> <54D80D38.3080708@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iP+lLc053bLZskikhMy1"
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: nick <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D80D38.3080708@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iP+lLc053bLZskikhMy1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-02-08 at 20:28 -0500, nick wrote:
>=20
> On 2015-02-08 08:26 PM, Jeff Kirsher wrote:
> > On Sun, 2015-02-08 at 17:21 -0800, Jeff Kirsher wrote:
> >> On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
> >>> Removes the outdated fix me comment in the
> >>> function,gb_acquire_swfw_sync_i210
> >>> for setting the variables, i and timeout to the intended correct
> >>> values for
> >>> the function,gb_acquire_swfw_sync_i210 to function correctly. This
> >>> comment is
> >>> no longer due to these values having been no changed in the last few
> >>> years and
> >>> no known issues have been found for these variables being set to thei=
r
> >>> current
> >>> values. Due to this the comment can now be removed as the values set
> >>> for these
> >>> variables are known to be correct after years of no known issues or
> >>> bugs related
> >>> to their current values.
> >>>
> >>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> >>> ---
> >>>  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
> >>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> Thank Nick, I will add your patch to my queue.
> >=20
> > Oh and the title should be "igb: Remove outdated ...", not
> > "net:ethernet:intel: Remove ..."
> >=20
> Jeff,
> Sorry about the title. Good to known for next time. Should I resend or=
=20
> will you fix the title for me?
> Cheers,
> Nick

I will fix the title.

--=-iP+lLc053bLZskikhMy1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2A1wAAoJEOVv75VaS+3O67UP/ie64R5kWUOMZDj3SO/2XJjf
RAVSLqyFYD2vplRuVQ5w92aAZ051tuc2A6rv9ik9btMBvmg94ADLtx8DdlL79Jmy
QbpMUWKTDgA2gB12DFv1l/0JCvgVqu6PMQvwdHaRh1+uTTW3AIJjXSOHENFZuOG4
m7FywNh+R1zahGohGgIhkLgpqQr8J5+8wtTK7iBPfgrwtxcMxT+vRUvHFET5m17t
StwFxWdOVDFK7iSWcKTUvljJ8taZz/JdBRj6LWIsSAujR/zvCKv3pbsqpj9E9IW5
8m/R9wiYD6vUliXgV2O9J5qTReSxJQGLKg25gaqX6IPvx3hTNf4IA6h+bcX4vDQV
orZKLxcm2B6XUou1hBG6Rv603I51eN1g2a18LM2Mcz7tMvaYk+A5VQnJMYQQpF/w
8m97oooENBY5n0AwAi+FggH7ORyEnpPabeFzA3YE5UuQZ4ZRX3IKnpoluhnMvtoB
hovDslDpDhizLX2nvAkUU5gjAKkrAl5MmTLFe2wWXbzsLfDABoguyWsEImodXw1n
ajXhX10KOUzXXhrBlCRL9aCi42EDr4ppxhjFxydi8VR4VpmPcoA8b0J3liPaZmK1
/6F9/Ez2JoKTe+6Ecn2RB22OJxebewQftBWjXxCMlEoTKQGl3BMIwrPhF0eloooM
m86mMAVf6IMvvNWfN+gB
=d7S0
-----END PGP SIGNATURE-----

--=-iP+lLc053bLZskikhMy1--
