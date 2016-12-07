From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 08/10] vsock/virtio: mark an internal function static
Date: Wed, 7 Dec 2016 14:09:10 +0000
Message-ID: <20161207140910.GD32099@stefanha-x1.localdomain>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-9-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8219234143552074653=="
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-9-git-send-email-mst@redhat.com>
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


--===============8219234143552074653==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UoPmpPX/dBe4BELn"
Content-Disposition: inline


--UoPmpPX/dBe4BELn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 06, 2016 at 05:41:00PM +0200, Michael S. Tsirkin wrote:
> virtio_transport_alloc_pkt is only used locally, make it static.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  net/vmw_vsock/virtio_transport_common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--UoPmpPX/dBe4BELn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSBgGAAoJEJykq7OBq3PIePQH/1bZho2OON6zmzFYNsw9VEnW
5s82sn6Gr5mQHQ+4sgBHXUyAGXDjo6jfS7pD0oSh/yvo7AuSczG71lF74CpHYrkm
kMnHYUheKLq5P5kplwbAa2pKY+HTEdMFQSmf2vIG/uNKlGGui8xbyXIZGY/peZvK
zs9siZzX1w5BbdO6YJpE2IWSzc/6bx047hetCVC3BcIqwhT/4D8bq8h648WEQfF6
4B7ZLVC53xkycBk7ju7zscRxv2HSMnhNwmnFOI44iKTIkJBz1n8Aq61p5dcWjjIj
JEmHFGxx7q02L3ehXOGdADpM3Gsxd/ZPtX5i3XL7fRK5OLIpbfOl0keJHybeKhA=
=JMSO
-----END PGP SIGNATURE-----

--UoPmpPX/dBe4BELn--

--===============8219234143552074653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8219234143552074653==--
