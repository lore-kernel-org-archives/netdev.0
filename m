From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v2 2/4] vhost-vsock: add pkt cancel capability
Date: Thu, 8 Dec 2016 09:51:49 +0000
Message-ID: <20161208095149.GD10780@stefanha-x1.localdomain>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
	<1481123652-80603-3-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0156785480539978965=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481123652-80603-3-git-send-email-bergwolf@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============0156785480539978965==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uxuisgdDHaNETlh8"
Content-Disposition: inline


--uxuisgdDHaNETlh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 11:14:10PM +0800, Peng Tao wrote:
> To allow canceling all packets of a connection.
>=20
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  drivers/vhost/vsock.c        | 41 ++++++++++++++++++++++++++++++++++++++=
+++
>  include/linux/virtio_vsock.h |  3 +++
>  2 files changed, 44 insertions(+)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--uxuisgdDHaNETlh8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSS00AAoJEJykq7OBq3PI10UIAKZproe+6OSKMJK+W/Y0+MUj
Jy+aMI1SCen5fd8mIzfa+t1qe9HPLagw2Lwcekuzf0kHNnXxoJSm+QILGJ3NBjji
S8ipgfi5ypEG4pn3N1A+WPPdyWQjlZYbvsEY5u8iltvjBPNsjwPO5gBO6QiSAB3g
vfLcDVs96GAFvFPOuHzOiORnnVNN5Nn2FhCb0gZQpkDGjhoOKHJ6LlRw1P1zamwN
Wb/eVNCV64IGrRmNAUXxUsCeXItP9AWBSxPYUUOEWNBhAzguwchKTHNT929VZVIX
cCgQ/KXI2YjnPpO2vpgEsS+NNP1nxeEExzuxn4erBSJfEsAFe62Fi2yEhbx5hTY=
=e3br
-----END PGP SIGNATURE-----

--uxuisgdDHaNETlh8--

--===============0156785480539978965==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============0156785480539978965==--
