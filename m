From: nhorman@redhat.com
Subject: Re: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Thu, 10 Mar 2005 07:08:03 -0500
Message-ID: <20050310120803.GA6341@hmsendeavour.rdu.redhat.com>
References: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain> <20050309211632.6f70fe41.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: Sridhar Samudrala <sri@us.ibm.com>, nhorman@redhat.com, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309211632.6f70fe41.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 09, 2005 at 09:16:32PM -0800, David S. Miller wrote:
> On Thu, 3 Mar 2005 00:32:12 +0530 (IST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>=20
> > Please apply the following SCTP patch submitted by Neil.
> >=20
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>=20
> This patch doesn't apply cleanly right now.  Could you
> please cook up a fresh version, and also supply a 2.4.x
> version of the patch as well?
>=20
> Thanks a lot Sridhar.

I'm sorry Dave, I must have built the patch against the latest RHEL4 kernel=
 and
not checked it against the bitkeeper head.  I'll rework the patch and repos=
t.

Thanks
Neil

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCMDijM+bEoZKnT6ERAkixAKCSb4NkIPVzDagYGSg/GTHsSiXlFgCcCLga
v8by9pZr1SDgmazAfDzVvs4=
=QMGC
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
