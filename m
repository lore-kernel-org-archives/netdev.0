From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 11:19:25 -0500
Message-ID: <20150930161925.GJ32625@saruman.tx.rr.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JsihDCElWRmQcbOr"
Cc: Felipe Balbi <balbi@ti.com>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	<target-devel@vger.kernel.org>, <cluster-devel@redhat.com>,
	<ocfs2-devel@oss.oracle.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150928133514.GB30453@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--JsihDCElWRmQcbOr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 28, 2015 at 03:35:14PM +0200, Christoph Hellwig wrote:
> On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> > this (and the other helper below) could be macros just fine.
>=20
> They could, but they shouldn't.  Inlines are always preferable over
> function-like macros.

says who ? And why ?

--=20
balbi

--JsihDCElWRmQcbOr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWDAuNAAoJEIaOsuA1yqRE/UsP/1QWOLcoeFtYju0iaiYIsX7r
8XTsgjd9C9qnOmU3VtuxAmL2MIDwvgdeODtAL+nxVP4PaaWOUhOhS1XsmsnEsRxQ
LfyMnp+8c30AIUoOp1wMQepFjUrvnpeC0jEXx+zKJMdSGyUc4+w/3iZbUfoUFTnn
zXEc/8dgar0sTOusKL4QtYgTHJbQNlU1DUxMAFNuveTbcR9UmyRogy1t0zwH0bKg
b1vkmw7JKZcAuTiq5pKUS04itgFSJasqEWvCdEf8tpfhVKXPuE5+0FjbvNNhTxjN
p3L2mdBM1AOEkoZNgLN7uam6tyBm8bYBwtBZP/T0HyiM2LLcySprs3xNaM5NEFha
o8fvFSqp0+lep8cqX8vreE2m5UacI1/urVh924IjXp97LUDbXmhDEBDxk269qCEb
6PAV/l39FDrdtb11Yp8g86VK5TP68GYY4KtJ3t+X61QY4jnZcsE1Nx6Q6doP8888
juwatBN7NKA5Z/ITLxkMvXZk8xQqhy2LMFwTFPxQvCx4AE+tIZV8tQGoogbSISZc
LuijXoo4jQ8pa9BRMq0669bUjx5/BXiZidM5LzhL/xFlDfDZ2qI/UJwH9dddpuXJ
UV65sqkLG6zPg2k22R815l7qc1MwV/vJJ3jWIy+1fXuxj/iu2OFdwSj0jMkjF87p
rTTetiCYfywEaZva8a6k
=ELev
-----END PGP SIGNATURE-----

--JsihDCElWRmQcbOr--
