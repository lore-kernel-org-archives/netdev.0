From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2 net 1/2] fm10k: Check tunnel header length in encap
 offload
Date: Thu, 13 Nov 2014 15:41:23 -0800
Message-ID: <1415922083.2454.33.camel@jtkirshe-mobl>
References: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GuZpi5xbYnHsqPXICOTQ"
Cc: netdev@vger.kernel.org, matthew.vick@intel.com,
	linux.nics@intel.com, therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GuZpi5xbYnHsqPXICOTQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 15:36 -0800, Joe Stringer wrote:
> fm10k supports up to 184 bytes of inner+outer headers. Add an initial
> check to fail encap offload if these are too large.
>=20
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> Matthew, I didn't see the equivalent patch on netdev so I went ahead
> and
> created it. If I've missed this somewhere, then please disregard.
>=20
> v2: First post.
> ---
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    6 ++++++
>  1 file changed, 6 insertions(+)

Thanks Joe, I will add your patch to my queue.

--=-GuZpi5xbYnHsqPXICOTQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZUGjAAoJEOVv75VaS+3OAFgQAJ6daVYXSbd2TWSe+vyooSPg
vT0DbbSpA7FJr6WboB5kVCNiythgsT6A0jSA83i/Ppd8idHdxgT9mb9HFoRKqikb
mW48LNjDfSxcMc2HVQRskJSOKPnhkSxe3rMN6Fdur6lNB8xrKDq7dkYMrpsIL6FR
dTqoSW8XfBefg97tiVzCZdyUX4+PrHPBbTYEKQHon3n8rrYtv9eL6kcEBhrFPli+
XH61dtsjKRxUZ44Fl0HPs224d5jItJcAOTwiGgrKyTNw1Wq3KMFLtHBirEZKlSdN
ijS8C7XP7ygG+Qbu9ixT6rVzolKmFB68xrypv2+hmOEr0u+CJOALQq530zTf/QBl
1arcPzC3kciYvZm2OOeO6QS6NaB4zJZY8YN3BNLkPTLsS5iTq+AmspMeFNxpi0VY
ew4vydmhHi5ThRZvQzv4MvOQbzS8yosUVniImGLgCPXykldEucEdpyaLgderH8zF
zcTKbhuhPF1fZ6pjEWGQzwLQnUfyhe4YIU9JkLdPYGzHxnxmN7ov4yMEfs58raXa
PPAR7O+gBiB4inNTIZGzqSZsTHZGvNTG+2qNW2VR7T9MI2gIcpZcLfEK4tTY7tnn
f5HbeB7shARjzhMJVig2QEfZ75xrSuq5kO2MkdxFhcemIi+iaTkqqnYFXo/aVNeC
fBpo8Iwytsh75nS8fR4M
=l1Y5
-----END PGP SIGNATURE-----

--=-GuZpi5xbYnHsqPXICOTQ--
