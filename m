From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 13:38:13 -0600
Message-ID: <200501071338.16621.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501071017.31751.jeremy.guthrie@berbee.com> <16862.57504.383176.640058@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2026825.t1k58qBlYN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16862.57504.383176.640058@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2026825.t1k58qBlYN
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 07 January 2005 01:18 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > Did my second email w/ the lnstat data not make it?
>  I see most zeroes
Is there a particular duration and count you want me to run for?  The snaps=
hot=20
should have been 60 one-second snapshots. =20

>  > >  cat /proc/net/softnet_stat
>  >
>  > total    droppped tsquz    Throttl  FR_hit   FR_succe FR_defer FR_def_o
>  >  cpu_coll
>  >
>  > > 9ba490f3 00000000 01281572 00000000 00000000 00000000 00000000
>  > > 00000000 002562c2 9939268d 00000000 010e42e9 00000000 00000000
>  > > 00000000 00000000 00000000 0028fe72
>  >
>  > Why do these drops not show up in the interface drop?
>
>  These are drops in the network stack not in the devices.


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart2026825.t1k58qBlYN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3uUoqtjaBHGZBeURAshBAJ9j0hZAuvcmr2HvVyZDlMyd5Va8ZwCfdVjW
m8mRjQ5TRwfYPnppWdPI2qo=
=aicE
-----END PGP SIGNATURE-----

--nextPart2026825.t1k58qBlYN--
