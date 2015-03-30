From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 56/86] intel/ixgb: use
	uapi/linux/pci_ids.h directly
Date: Mon, 30 Mar 2015 12:04:43 -0700
Message-ID: <1427742283.2497.92.camel@jtkirshe-mobl>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
	<1427635734-24786-57-git-send-email-mst@redhat.com>
	<1427673301.2497.83.camel@jtkirshe-mobl>
	<CAOaVG15C+4_+m-GFCB0V-G0fBGwj4fg7VsWmgwB+QNDWT136bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7662981783225296853=="
Cc: Linux NICS <linux.nics@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	John Ronciak <john.ronciak@intel.com>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAOaVG15C+4_+m-GFCB0V-G0fBGwj4fg7VsWmgwB+QNDWT136bA@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============7662981783225296853==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-U33FI1Q+XPX2cQTObldZ"


--=-U33FI1Q+XPX2cQTObldZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-29 at 22:30 -0700, Stephen Hemminger wrote:
> Patch was rejected upstream by Greg

Thanks for the update Stephen, I will drop the patch.

> On Sun, Mar 29, 2015 at 4:55 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>         On Sun, 2015-03-29 at 15:41 +0200, Michael S. Tsirkin wrote:
>         > Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
>         > use the new header directly so we can drop
>         > the wrapper in include/linux/pci_ids.h.
>         >
>         > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>         > ---
>         >  drivers/net/ethernet/intel/ixgb/ixgb_hw.c | 2 +-
>         >  1 file changed, 1 insertion(+), 1 deletion(-)
>        =20
>         Thanks Michael, I will add your patch to my queue.
>         --
>         git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue=
.git
>         dev-queue



--=-U33FI1Q+XPX2cQTObldZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGZ5LAAoJEOVv75VaS+3OIPUP/iCCeBh41Hg/+5EgwJe2j+6e
aVSsUo0/TqUef1ELlXG+VaC43DQ95Vs55YfTRD5LkgGB1uEPlAUXj+HnT23Tzwsi
UvXJ7UmvmXl301+ipOExdjhFiAr032YX6DsWKY5XWwDHLdrgysK7H73gHmoEa0lA
//YwIf06Hs557VIlhLeurO77dggEfuGL2uHZ2bJzP/i6MNRD0wJHFRV1ep8F0wY8
Q3V9LLJ497Rp8yEnFjjVt6pBcWb9PGA0NFFpSBh+m3/cF+RtaxPavpQ2wZmJP7P8
3eey3x7qBfAlAYpECH+g/KGJEhFK9utBaDA3lDoN4ARrwUu8MrR8mf3YzZ7T3JRN
Rr1TIKf1QrBtcHn9AKKsFV+SWBT+xsjksihc7r6KNcblZsGgOfSzvJQJpOflNDDk
eQyDCJ3YxBOmWzSu1oIZXHY0j4erf23yllNVXS1kz/AWeCWnbSkRvnYm7gcAGc+8
b/aDJmXPP4Rv2gnOuuqY24Tv10kPEl6qux+tfhh9Hq6j/ZmaFBUvitADe7QOUTah
NMYB9S5gkWpj9aYRuDFBrnHCQZoEd021SlWHxnc7HQ2YkeIgC8PKC4M5YtKsJOWM
vfJBlLJBq1fpSErKSvBSmAzDry3BIx8uFGdk9AolajRQIi1tlrG9QldViuPIXk/h
bLWHTN/+1CulPJCVIyZV
=q85b
-----END PGP SIGNATURE-----

--=-U33FI1Q+XPX2cQTObldZ--



--===============7662981783225296853==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
--===============7662981783225296853==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7662981783225296853==--
