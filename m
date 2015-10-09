From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store methods
Date: Fri, 9 Oct 2015 16:19:57 -0500
Message-ID: <87io6fu4ci.fsf@saruman.tx.rr.com>
References: <1443879179-22280-1-git-send-email-hch@lst.de> <1443879179-22280-3-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Cc: Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	<target-devel@vger.kernel.org>, <cluster-devel@redhat.com>,
	<ocfs2-devel@oss.oracle.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1443879179-22280-3-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Hi,

Christoph Hellwig <hch@lst.de> writes:
> To simplify the configfs interface and remove boilerplate code that also
> causes binary bloat.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

I suppose this depends on other fs/configfs changes ?

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWGC9+AAoJEIaOsuA1yqRESncP/2gLswrEp+T41rgBfpNNx6p/
mDqm9LW2bIFTtufk9ujhuxnhi+pEMdN1XMHaivuYzjJizumgJJkoCCelVzyfCmI0
LVhuZ/iflwrB6RzpsuqzmK9PoJWy25fs+/qlyEwrrPnc7POR6xtWZLjkqpa7bEXR
a/WniI7NcTOeqFF6WzgnO9vWeQK88vv0RuKMBiGcD1FsSzpzLiebfbGFDP6vlobA
6bjqMBnmYZVKil7HHVSKJSFLkFsYSQWhjyjwHy6PlI/fJZlXITzwVbMbtcKy/yG4
d/CWaKas/O3Dj3YHxQCTJ8noLXnXx+keNDzHjB46ho1dKPA4FoQDOsUuX51kcBx7
765R8J0FpDk1yW1x9QWKn+DIMGbL2HsMjG2NKLz80N1lp6x802SF2dosAZBkGmIP
kpEQbgrsxYx++4rcT+WenmurrEa4WYgHrPbT2yXAv3V62lZkbMN5GFbFCvhJwPo4
T9rCNBp6zuCEwaaLW5vZiDIeCtnN7x2JIR5IiA1u4YQHH66hIRea0WYIbp/9+cKf
8P+1OFF4ZC+MbTYyexhElKHDE23kJKtsKnMcM+t/ZYQWmpGFp4doZnhrnVJpn0pj
7h9MWPI9jdvbSmrcLvzgUJCoKe6EN0+KupoH02Tq8rfiQBPrHxKlyXSphnqMMpoE
Zle/Y9jiO8fztYRoYo2b
=Q7dh
-----END PGP SIGNATURE-----
--=-=-=--
