From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: linux-next: just chaeking correctness of the infiniband tree
Date: Fri, 21 Jun 2013 10:09:28 +1000
Message-ID: <20130621100928.36a0ccf45e310f02a4dff53a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Jun_2013_10_09_28_+1000_=zBCq/iQoRxiHrq8"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Jun_2013_10_09_28_+1000_=zBCq/iQoRxiHrq8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

I noticed that the infiniband tree is now based on the net-next tree.  I
assume that is deliberate?  I do have to question how much testing that
tree has had since it is now based on a tree that Dave only released in
the last 24 hours ...

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

--Signature=_Fri__21_Jun_2013_10_09_28_+1000_=zBCq/iQoRxiHrq8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRw5m8AAoJEECxmPOUX5FE8kQQAKVdpztXG+0cUurzFcDmV3Aw
yZGkP22IurHYaKLsp/aIFJqmS4H8AmZP0wff/5w+EKj7fLVdjJyhCLuJCXZkOnGy
GF2aHd+L29XDUugs8bOlw7Xgr0jN33/mZ9mVUaLk88zqCrePcFZiKXJ4qYud6Tjg
MY/tO/yIQEzCwbAL+WBMliQFZlQOAzLmx9mZIwwvN8GiR4SUydFs0eFNpQTPRw69
wHQHBaLbymqkH0vkWF4hUq5kpJJ3J1Sp676a0Y56BMAx667hAncsdhsXBC8jKyM2
IlusUX/GXbW7QCCv7pdO+Ve9KX8b2OcMIlnF95gCnMRd+bgqy1Xwr/ejzBqEZtts
OUSf+KZrmTfb1uXYH65u8BYkBtN5SJWzvdZ7qW1o8eSK41v2AaHi7GqMjDi+zYLX
eI99k2MsuKMLb94zJeCAU2M4mHVWgxZuYkz0QaewMlldVi6ZnKxQwv8+HutI334Y
nBRoOWDFzyIuYAx09auaxAzaS2VrO1j1xKKzhqIvGbpXCiTLY0kLieNJl4eT1nUl
ZCOpKC2PXS6q3SviK3EeWUlbbtlSWhYyEzXb2LaaHcm2Oq3dwWmcLYEobqqH7YB1
VeubJh61HvmoIQDygFFFBvOLAaQApUnSd4VJj24p1Tez55w7HVusvZKGv77f/lqS
rPHYVp7oOXR+/A3MLOxS
=T063
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Jun_2013_10_09_28_+1000_=zBCq/iQoRxiHrq8--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
