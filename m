From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 15:46:29 -0600
Message-ID: <200501061546.32116.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501061520.02362.jeremy.guthrie@berbee.com> <16861.44870.968343.578778@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6041310.sTJrLWFtUM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16861.44870.968343.578778@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart6041310.sTJrLWFtUM
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 January 2005 03:36 pm, Robert Olsson wrote:
>  > I should have caught that sooner.   8(  Well, I have a window of
>  > opportunity here.  If you want I can still provide a broken environment
>  > but that seems pointless while NAPI is not acting right... what is
>  > evident is that this will run better till we start to bump up against
>  > the top of CPU0.
>
>  I don't follow...
Technically by turning off NAPI, I have 'solved' my short term packet loss=
=20
problem.

However I can still provide you a window to go through further troubleshoot=
ing=20
if it is beneficial.

>  The stats didn't show any numbers so we don't know your load.
Are you referring to the # of entries in the rt_cache table?

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart6041310.sTJrLWFtUM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3bG4qtjaBHGZBeURAlh6AKCGTkaEa8sKvtg4k1Un3T474YTG/ACeLIZb
2eeMHU7sz23LBGz7Gv/NpKA=
=cn/n
-----END PGP SIGNATURE-----

--nextPart6041310.sTJrLWFtUM--
