From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 0/6] VSOCK: revert virtio-vsock until device spec is
 finalized
Date: Wed, 9 Dec 2015 10:39:28 +0800
Message-ID: <20151209023928.GA24211@stefanha-x1.localdomain>
References: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
 <20151208.112655.353902854757115664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: netdev@vger.kernel.org, mbenjamin@redhat.com, kvm@vger.kernel.org,
	christoffer.dall@linaro.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151208.112655.353902854757115664.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 08, 2015 at 11:26:55AM -0500, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Tue,  8 Dec 2015 19:57:30 +0800
>=20
> > Please revert for now.
>=20
> Please don't revert it piece by piece like this.
>=20
> Instead, send me one big revert commit that undoes the whole
> thing.  There is even a merge commit that you can use to
> create that revert cleanly.

Okay.

Stefan

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWZ5RgAAoJEJykq7OBq3PI3GMH/0hrBx0hcoUgtqN++eM0YGOL
+EliNMSqqFPK5BNwI76OSqHfQCjySzq9ueTY0eXkym8xusgBh6UrYM4a0c8I1QjZ
ItOgEpOuhoJp0jcwuFXXJtjh9hJYUr2a2qYXvDc1wocwfCEuOrlUhOKbDsV+5NIz
PuKc/Ly+OVXMrmuIRcQoDf3yo1xpH8A0BhPzfyG9C6/7WJiJvUewQLmPb04iqt3E
mgOmwElXQAZd6GRqJdl6gXt1P4xfyPjpcizgvH3wR3kbqZwMw/mYPjNh1G3QmICa
V901xXVAeaNAtsoP9iV2spluJj7L4YYd+VQfs3Y4iNGnCwn1i2nDvZW7HmZWUpk=
=x3Nj
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
