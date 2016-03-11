From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [V9fs-developer] [PATCH] net/9p: convert to new CQ API
Date: Thu, 10 Mar 2016 21:20:46 -0500
Message-ID: <56E22B7E.7030400@redhat.com>
References: <1456565151-27115-1-git-send-email-hch@lst.de>
 <1456565151-27115-2-git-send-email-hch@lst.de>
 <20160227154957.GA21186@nautica> <20160303083606.GA13828@lst.de>
 <20160308143837.GA10208@nautica>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="7Q1MUKt8q3XjgVNm6vwI2WLXCjhSUgdQh"
Cc: v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dominique Martinet <asmadeus-9aU+PIKW3UvdtAWm4Da02A@public.gmane.org>,
	Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160308143837.GA10208@nautica>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7Q1MUKt8q3XjgVNm6vwI2WLXCjhSUgdQh
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/08/2016 09:38 AM, Dominique Martinet wrote:
> Christoph Hellwig wrote on Thu, Mar 03, 2016:
>> New version with the nits fixed below.  Now that checkpath started
>> a stupid warning about not using tabs for indentation which I've
>> ignored here and will take up in my usual fights against Joes
>> idicotic opinions separately..
>=20
> Thanks for the nitpicks, I can confirm it works as expected as well so
> all good with me.
> I like the new CQ interface :)
>=20
> (if someone adds an Acked-by please use dominique.martinet-KCE40YydGKI@public.gmane.org for m=
y
> mail; sorry for the split personality)
>=20

Since I haven't heard anyone else say they are picking this up, I've
grabbed it for 4.6.  Thanks.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--7Q1MUKt8q3XjgVNm6vwI2WLXCjhSUgdQh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJW4it+AAoJELgmozMOVy/d+lwQAIcO0jHGKPnDJ9YBJjaVRIoi
DQoipgF0WtK+mvIZKQcwh5japjUlEL64LFsuSEvptYVls7BdRwNLFK91T5OHQLMW
hE5VMYopsy3Qt8iFj1cXVFST22Ln5lqaaoI5nEbu6lpG0t+md5J0CeTvXBP7F85M
Wnutg7UuXR51yxjN2HVAHEhkbqm482uX/e/VsJ2YJJYdB2QJ24aITuKqbPWuNTbL
Y0hNBBD4oAlcMpH/lz/09pIcQMHgAyXwyC3Y/AYTOGvgTJ2Zhvr8cDnGD5Fb3zCm
llLJKmyDYZvWIU/bE1Dfllz+OBl1ugf6kPzQuUIoH16pLPLVXwvLAVx7JMXx/kF6
pKy0qF8XMFadWBR6kPUnbk4z/yVoH0JqUfpxju7CXBhDS8qWd9jZZnuQGqLk7rvZ
k0vYo0/+mpfeYEBSsO4xNPj6UhhcLCLHKXr9hHb0mmblQez/78QOO9Ft9i39Ju4m
UE2Gg5nYJaJAy3tkAGsih6pCT2wXZNx4QKatrX/M+E4JTmyXVnZShDGzAY86a4Js
BiiguPIQQskeFBQi5KAUMkNQGoNbRHAsi8a1c+F3sR3vczdP61Skr1AQzjUrpRwM
NvbxOhnYBtx+NFYejRDRqiH/ePaaJ2aA0pN3ugegxBLofptTNFXFnOOrYeoTAidW
5xvF7dKMMs7Sb9v3bYzq
=O2AJ
-----END PGP SIGNATURE-----

--7Q1MUKt8q3XjgVNm6vwI2WLXCjhSUgdQh--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
