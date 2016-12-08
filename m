From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v2 3/4] vsock: add pkt cancel capability
Date: Thu, 8 Dec 2016 09:54:25 +0000
Message-ID: <20161208095425.GE10780@stefanha-x1.localdomain>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
	<1481123652-80603-4-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6913403136612007002=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481123652-80603-4-git-send-email-bergwolf@gmail.com>
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


--===============6913403136612007002==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9crTWz/Z+Zyzu20v"
Content-Disposition: inline


--9crTWz/Z+Zyzu20v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 07, 2016 at 11:14:11PM +0800, Peng Tao wrote:
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  net/vmw_vsock/virtio_transport.c | 42 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--9crTWz/Z+Zyzu20v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSS3RAAoJEJykq7OBq3PIIGgH/jxCmDUyLfkIAKpIg12l9yNI
ahzZC2vmP0o/M+2GjCgjGiROAaTUTDX/ybfGoS63COVlR0ToH9xYWFxkOk5Mbf7c
HlHUTVUyBdfWAGG+hzNfmFjskhYNeN8eXqoCHifZxAqRyJJFqJW40voKavi0/aLK
ETyLWw7uOlw51n6/c+2D0gKYcDHKAlXIIDeOBCiZKj29mx1dBqBrccsPrlXRGONb
767E3rU34jBq7gg+MDoITOea1xEJhYIoL9ZbbEn6zDktB4KN94elkfrvkS7j8aIo
zJHYzZolrWKcWl+NAWXkpTYQFZb2pzUzRY+G9eurbQ+jOo8S1TMeyf1GVv6gGhQ=
=ZRXm
-----END PGP SIGNATURE-----

--9crTWz/Z+Zyzu20v--

--===============6913403136612007002==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6913403136612007002==--
