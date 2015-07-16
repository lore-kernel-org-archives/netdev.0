From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [virtio-dev] [PATCH] virtio_net: don't require ANY_LAYOUT with
 VERSION_1
Date: Thu, 16 Jul 2015 11:29:17 +0100
Message-ID: <20150716102917.GE3963@stefanha-thinkpad.redhat.com>
References: <1436963135-16592-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dFWYt1i2NyOo1oI9"
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	virtio-dev@lists.oasis-open.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436963135-16592-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dFWYt1i2NyOo1oI9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 15, 2015 at 03:26:19PM +0300, Michael S. Tsirkin wrote:
> ANY_LAYOUT is a compatibility feature. It's implied
> for VERSION_1 devices, and non-transitional devices
> might not offer it. Change code to behave accordingly.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--dFWYt1i2NyOo1oI9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVp4d9AAoJEJykq7OBq3PIG94H/iJAu4wJ2KIg5FJc2zF8CWKg
JJfR9Fej2SHIkIyE/7AqNNaqUtAWoyFvHwRByVOaa2p+1Hck0vAbnRf2HQwkmmR4
nBM3jrots8M0iGZsXYug/Us5PLkP36Ehgjo4XDrNbZ7jfP7oLQYpfs80y4K8Rxnp
CwKjWmPflAlQqUkKgzWU4qzWuwF9b/kxKiRHETJ1fygwLlZw65GuhqpnQOWqVbQ2
GoBOliTS19jfkh/EoS21PkqKLHP9gGWlIV5aFDPxuFdlvZ79+QNrYq7pMwL3QkE4
MxQoScSBdrqRljsvGKLrNOKuZYQVCeIGr7qXZ4DnSL4C6H5y4nyLebK4BBNlHN8=
=L1ou
-----END PGP SIGNATURE-----

--dFWYt1i2NyOo1oI9--
