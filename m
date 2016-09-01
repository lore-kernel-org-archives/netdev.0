From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC 4/9] ipv6: sr: add support for SRH encapsulation and injection
 with lwtunnels
Date: Thu, 1 Sep 2016 15:32:22 +0200
Message-ID: <57C82DE6.9050508@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be> <1472226767-9904-5-git-send-email-david.lebrun@uclouvain.be> <57C44C38.4010203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="9slUSN731aSx5c0DhTek2dlU4hQHxDEot"
Cc: <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:55008 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754330AbcIANcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:32:13 -0400
In-Reply-To: <57C44C38.4010203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--9slUSN731aSx5c0DhTek2dlU4hQHxDEot
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/29/2016 04:52 PM, Roopa Prabhu wrote:
> You will need to account for lwtunnel headroom ?
> https://patchwork.ozlabs.org/patch/662632/
>=20
> thanks,
> Roopa

Indeed, thanks

David


--9slUSN731aSx5c0DhTek2dlU4hQHxDEot
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfILeYACgkQjbzn67sZ6ANHxwCfdK7c275NV2pN8DdgYduHHVIw
En0An1ntigh6r4EWWqyK+TwC7nqwIWag
=sOek
-----END PGP SIGNATURE-----

--9slUSN731aSx5c0DhTek2dlU4hQHxDEot--
