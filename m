From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Where Linux 802.11x support needs work
Date: Tue, 25 Jan 2005 23:41:20 -0500
Message-ID: <200501252341.27041.flamingice@sourmilk.net>
References: <20050126024039.GA25326@bougret.hpl.hp.com> <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3045895.NHPOaLhEQL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart3045895.NHPOaLhEQL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 25 January 2005 11:03 pm, Dan Williams wrote:
> >  One of the big item not mentionned by you is the in-kernel
> > 802.11 stack (native frames and management). If done right, I guess it
> > would mostly be transparent to you...
>
> You know, I was thinking of it and I just forgot to put it on the list.
> If you're including madwifi and ipw2x00, we have a grand total of what, 3
> or 4 802.11 stacks in the kernel at the same time?  (madwifi,
> orinoco/hermes, ipw2x00, linux-wlan-ng)
>
Only orinoco/hermes is in the kernel, and that doesn't really have much of =
an=20
802.11 stack, since most things are done in hardware. Madwifi has a fairly=
=20
complete 802.11 stack (ported from netbsd), and so does adm8211. Dunno abou=
t=20
ipw2x00.

=2DMichael Wu

--nextPart3045895.NHPOaLhEQL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB9x93yWWBbDEe0UIRAvAfAKCEqvmMfjxGKcwFuEB30h7iozt4vQCggMhY
ThcRwvN4ggQ0sNNt/OzdFD8=
=JW0D
-----END PGP SIGNATURE-----

--nextPart3045895.NHPOaLhEQL--
