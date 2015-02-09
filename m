From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me
 comment in the function, gb_acquire_swfw_sync_i210
Date: Sun, 08 Feb 2015 17:21:29 -0800
Message-ID: <1423444889.2589.165.camel@jtkirshe-mobl>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6895823312229336743=="
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============6895823312229336743==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-p8eMhms2a1UVvkYpLtQ0"


--=-p8eMhms2a1UVvkYpLtQ0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-02-08 at 00:21 -0500, Nicholas Krause wrote:
> Removes the outdated fix me comment in the
> function,gb_acquire_swfw_sync_i210
> for setting the variables, i and timeout to the intended correct
> values for
> the function,gb_acquire_swfw_sync_i210 to function correctly. This
> comment is
> no longer due to these values having been no changed in the last few
> years and
> no known issues have been found for these variables being set to their
> current
> values. Due to this the comment can now be removed as the values set
> for these
> variables are known to be correct after years of no known issues or
> bugs related
> to their current values.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thank Nick, I will add your patch to my queue.

--=-p8eMhms2a1UVvkYpLtQ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2AuZAAoJEOVv75VaS+3OsRkQAIoWQbaq/DFtz1+UG6wj4khm
zlEmQjv8tiSXCiFb+vcMiYgPOKUWRBwoAtETVDApfYeUws0ksFmSkmgD+wZRIRYi
X8SJAiYGPajanGOTUT9CxaZbBlT9gC2/8397oBcFt6K3HMmuixQ7j9Ff1I2Qp1rP
d6HFoDl0sEawtWBaVeOCasCweIEsM6Oams5eYQZvxe1CPqugI3puSO3uYDnG/xdt
xU+6oBbocVnGHyvUjpJpY93l+bg1RO09oTRTwB2nlfCWccyRRGplT2T/BVnHCFxw
bKtKInBVeVV+lbhh8AdGw+2+khWEILfPID8eERndoGacKoa+B5ntCw7/gnJdIYaN
eBpFP4vjwDNquKBJm7eAY4MK7wwljN4wdd3vv9Elg1X6A0ziEOb6X/1bs6/7RRBP
LeC6Widu8+mYnf0KUVfoGv/l2n8Sa890AlPDpRjj6Yq6++g/1ViiCIePwNIfD6n9
EATaAWDEvZBTzMEIdF/oWD05BdyU0NjRhlW5Y9iYbHLQfjI9g4Uo2OL/Jenr8g26
kTdFtqTNlncMegUdNzFhTS8YPq9YogAk+zOOM8RWHUBZMoZ3aPNbbuOoDREFvOlG
ZCrQWUJwEcWt3tsCMiZW8SOEYhyk1wOTmn/e6ILutIf/L92gBgf7WF9Vfgad1g5S
xZ+UqWm7RlIEC9m5OkC1
=rz5T
-----END PGP SIGNATURE-----

--=-p8eMhms2a1UVvkYpLtQ0--



--===============6895823312229336743==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
--===============6895823312229336743==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============6895823312229336743==--
