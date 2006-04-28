From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 22/32] rt2x00: Allocate ring structures in single array
Date: Fri, 28 Apr 2006 16:33:44 +0200
Message-ID: <200604281633.44521.IvDoorn@gmail.com>
References: <200604280003.14287.IvDoorn@gmail.com> <200604281625.13165.IvDoorn@gmail.com> <20060428163055.0656bc08@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2922496.OKAUinvAL9";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.185]:36014 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965209AbWD1Ocf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:32:35 -0400
Received: by nproxy.gmail.com with SMTP id n29so1590889nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:32:34 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060428163055.0656bc08@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2922496.OKAUinvAL9
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 16:30, Jiri Benc wrote:
> On Fri, 28 Apr 2006 16:25:09 +0200, Ivo van Doorn wrote:
> > I am not really fan on such messages. But when the control->queue is in=
deed
> > invalid, it is a serious bug. Perhaps a BUG() should be used as well?
> > If so, I'll put it into a new patch along with the fixes below.
>=20
> BUG() is not a good idea, this is not critical enough to panic the kernel.

Ok, I"ll just change the debug message then. :)

Thanks.

--nextPart2922496.OKAUinvAL9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUifIaqndE37Em0gRArrtAKCL4IIPyLNcqo3hMKmwVzKStnHlzgCfQgUy
8D2IuKdwDoLnoa6m4IJYLVs=
=Qphl
-----END PGP SIGNATURE-----

--nextPart2922496.OKAUinvAL9--
