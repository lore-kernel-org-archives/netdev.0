From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 03/12] e1000e: add check on e1e_wphy() return value
Date: Thu, 10 Aug 2017 20:54:24 -0700
Message-ID: <1502423664.5735.8.camel@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
         <20170809214746.28139-4-jeffrey.t.kirsher@intel.com>
         <1502387812.2219.44.camel@perches.com>
         <c36867bd-fcb1-40b6-4f6e-b3ad2e6360dc@embeddedor.com>
         <1502420020.3099.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-U0jTgCeAbP0vwxZQoIYy"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Joe Perches <joe@perches.com>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47952 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751691AbdHKDyd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 23:54:33 -0400
In-Reply-To: <1502420020.3099.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-U0jTgCeAbP0vwxZQoIYy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-08-10 at 19:53 -0700, Joe Perches wrote:
> On Thu, 2017-08-10 at 21:47 -0500, Gustavo A. R. Silva wrote:
> > Hello everybody,
> >=20
> > I'm a little confused. Is this patch causing any trouble?
>=20
> Not to me.  I no longer have an e1000e.
>=20
> Given the commit message, this just seemed to be a patch
> that _might_ cause an issue if this code patch is actually
> untested.
>=20
> Compilation wise, it's obviously fine.

Fortunately, I have all patches submitted to me thoroughly tested.  It
was a good catch, and we confirmed it does provide a valid fix.
--=-U0jTgCeAbP0vwxZQoIYy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmNKnAACgkQ5W/vlVpL
7c48VA//UYHQCYhWxLbXPqYbfHmxmALYmMOf00p2EuoNakYHBn7jZ8o2oVGgHSHl
5trSuF/24DChxDSA9BQiyslgstODtL+w4K5d11NlEIonSk+z78orX9XQynwEOMum
AAre4SPQzi87GuIqALXbKyxgmqzjfTCpok6TFrWq2FAmV6SxZsO/AB3yJ2l+/t5K
J1zMr9Y07OtUzVkgp/ty5yXVHKM9N0IOJK8L80TUsgZ2OhyJFPrjWYV2ugXxKq1t
lxOe/rNeTtUHgbtxMJWB/h2AW1n6u7N1pxeLw7LZ5Ux2CvqfrbWPE9XXUURF1AC5
0u8Oh/sh1mLgN3yLMzJ0+3OLZ8+XSuCSpJmEjhzvcPldvXhw39ZTb9sQnM/9Qp0r
UZt+f9+zZUP900VIux8D4XNCaQnbF+0l5ndnVm46cytiMfWyVVZLrlnDYHW8kZW/
R9RYcGJ0yklC4qMzQBKvAAamP31ELGYach42Td76gw9/STFWAOUbzQPqMYY+JNGG
iSMvu14wf+M8ztpZ+P8Jq6pD4J93iN5EoMMjjiUEA0NZSz2oxws/tQVJShzwW54h
yNDBrP8HJ4pV3tlPNCcdW+wiG6HNfgJ+BfXBievE8esGWTlY+1/oPh0l/twn5F62
JnjBYaFcuJGKm5LISGQhdK0om+Cqs0+7BziegHJ2hvN/BjSDGag=
=lLC5
-----END PGP SIGNATURE-----

--=-U0jTgCeAbP0vwxZQoIYy--
