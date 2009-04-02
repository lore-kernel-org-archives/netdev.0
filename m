From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 08:52:51 -0400
Message-ID: <49D4B523.9020802@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig43FAAC99DF00DB24922CEDCE"
Cc: Avi Kivity <avi@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:34312 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbZDBMue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 08:50:34 -0400
In-Reply-To: <49D4B4A3.5070008@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig43FAAC99DF00DB24922CEDCE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:
> Rusty Russell wrote:
>  =20
>
>>  there will *never* be another packet in the queue
>> at this point, since it wasn't running.
>>  =20
>>    =20
> Yep, and I'll be the first to admit that my design only looks forward. =

>  =20
To clarify, I am referring to the internal design of the venet-tap
only.  The general vbus architecture makes no such policy decisions.

-Greg


--------------enig43FAAC99DF00DB24922CEDCE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUtSMACgkQlOSOBdgZUxkOjwCfZal+bMV47PK5hMMJosKdkkYo
wA0AnAm/K+VL6QhsIbYV9oqsMfRXWqxD
=YN4A
-----END PGP SIGNATURE-----

--------------enig43FAAC99DF00DB24922CEDCE--
