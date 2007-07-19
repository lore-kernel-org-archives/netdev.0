From: "=?utf-8?q?S=2E=C3=87a=C4=9Flar?= Onur" <caglar@pardus.org.tr>
Subject: Re: 2.6.22-git: known regressions with patches
Date: Thu, 19 Jul 2007 20:08:09 +0300
Message-ID: <200707192008.15147.caglar@pardus.org.tr>
References: <469F92B8.5090809@googlemail.com>
Reply-To: caglar@pardus.org.tr
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3915519.YtECA2XLpR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Giacomo Catenazzi <cate@cateee.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Jens Axboe <axboe@suse.de>,
	"Peter M. Jones" <pjones@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Meelis Roos <mroos@linux.ee>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:49898 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S940342AbXGSRJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 13:09:09 -0400
In-Reply-To: <469F92B8.5090809@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3915519.YtECA2XLpR
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Michal;

19 Tem 2007 Per tarihinde, Michal Piotrowski =C5=9Funlar=C4=B1 yazm=C4=B1=
=C5=9Ft=C4=B1:=20
> Block layer
>
> Subject         : bsg.c:(.init.text+0x43d): undefined reference to
> `scsi_register_interface' References      :
> http://lkml.org/lkml/2007/7/16/343
> Last known good : ?
> Submitter       : Larry Finger <Larry.Finger@lwfinger.net>
> Caused-By       : ?
> Handled-By      : S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
> Patch           : http://lkml.org/lkml/2007/7/16/380
> Status          : patch available

After a off-list discussion this was solved with Linus's commit [1], so ple=
ase=20
drop that one

[1]=20
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
it;h=3D29417b899a77aaba1c060f5e123db4f50006f58a

Cheers
=2D-=20
S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
http://cekirdek.pardus.org.tr/~caglar/

Linux is like living in a teepee. No Windows, no Gates and an Apache in hou=
se!

--nextPart3915519.YtECA2XLpR
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4 (GNU/Linux)

iD8DBQBGn5p+y7E6i0LKo6YRAowhAKDUsRQBQpbQp7lgebGtEYI44np7hwCfbRpq
byayx/iQGIhdU7aGZXDOErA=
=tmqV
-----END PGP SIGNATURE-----

--nextPart3915519.YtECA2XLpR--
