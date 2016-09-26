From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v5] virtio-vsock: Add timer to handle OOM situations
Date: Mon, 26 Sep 2016 14:19:45 +0100
Message-ID: <20160926131945.GB14950@stefanha-x1.localdomain>
References: <20160812140208.16772-1-ggarcia@deic.uab.cat>
 <f7998fa5-e0ed-d8f7-0443-a1e0f9058ad1@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="8GpibOaaTibBMecb"
Cc: netdev@vger.kernel.org, Gerard Garcia <ggarcia@abra.uab.cat>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41442 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965709AbcIZNTs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 09:19:48 -0400
Content-Disposition: inline
In-Reply-To: <f7998fa5-e0ed-d8f7-0443-a1e0f9058ad1@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8GpibOaaTibBMecb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 05, 2016 at 12:30:29PM +0200, Gerard Garcia wrote:
> On 08/12/2016 04:02 PM, ggarcia@deic.uab.cat wrote:
> > From: Gerard Garcia <ggarcia@deic.uab.cat>
> >=20
> > Set up a rx timer to avoid packets being discarded when there is no
> > available memory in the host.
> >=20
> > Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> > Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> >=20
>=20
> Seems that this patch and [PATCH v3] virtio-vsock: Fix unbound rx buffer
> weren't applied, is there something missing that needs to be fixed?

Michael: Ping

I have reviewed this patch.

Stefan

--8GpibOaaTibBMecb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJX6SBxAAoJEJykq7OBq3PIKFUIAJnmUzpZ7/KaocRFQqWP7ul2
5/hUZ7PqOrr3F66s4k9aqdvwsbo1M7bwogTg1Mtq9DfPCCHnwq93dCxDUlEaS7eW
jNUGjiF+xT0x8RQC+UUWf8MFE/AZTSjU0BnUJW5WpwQMmvte7lSVsNg6QoP/j3Ev
75av9i8h5DQzsD+4UBqiRhrmuknh/3eGNeNnR6j9wa+18idGfKFS0z4Re9P1PAEH
ecmzGrHxONhWknpWImjeLeFfmC/+6wwZBeub4Xjz9ifNtQbXxwureYxQfwKHAUzw
mVydUi9j3YiwgUl7AqsPQzBvVgYlO933c2f0YHZQKqR8kF3ACOpmkht7U9/blDc=
=vbEH
-----END PGP SIGNATURE-----

--8GpibOaaTibBMecb--
