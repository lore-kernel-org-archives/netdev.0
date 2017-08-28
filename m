From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: add support for seg6
 l2encap mode
Date: Mon, 28 Aug 2017 20:11:59 +0100
Message-ID: <99974f81-90e8-c6ff-7068-2beb871cb84d@uclouvain.be>
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
 <20170828190525.15655-2-david.lebrun@uclouvain.be>
 <20170828120724.53904cbf@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="1FhqUu9wvEGWuDkAoub0tUwsvAMqVcMdh"
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:41426 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751225AbdH1TLb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:11:31 -0400
In-Reply-To: <20170828120724.53904cbf@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--1FhqUu9wvEGWuDkAoub0tUwsvAMqVcMdh
Content-Type: multipart/mixed; boundary="4kWoXsBE0t94KeEX4bhLFvNHmVBD2uviW"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org
Message-ID: <99974f81-90e8-c6ff-7068-2beb871cb84d@uclouvain.be>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: add support for seg6
 l2encap mode
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
 <20170828190525.15655-2-david.lebrun@uclouvain.be>
 <20170828120724.53904cbf@xeon-e3>
In-Reply-To: <20170828120724.53904cbf@xeon-e3>

--4kWoXsBE0t94KeEX4bhLFvNHmVBD2uviW
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/28/2017 08:07 PM, Stephen Hemminger wrote:
> Since these values probably will grow over time, it would make
> sense to have this a name/value table.

I wasn't sure if it was worth it for 3 values. I do not foresee a large
growth either, but I will send a v2 will a table anyway

David


--4kWoXsBE0t94KeEX4bhLFvNHmVBD2uviW--

--1FhqUu9wvEGWuDkAoub0tUwsvAMqVcMdh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWaRq/wAKCRCNvOfruxno
A6ObAKCLUfXwlbXWQQzldM/NzwtCzc5sgwCgizqtS05K4A8LAqxXiortrhXLuAA=
=isXW
-----END PGP SIGNATURE-----

--1FhqUu9wvEGWuDkAoub0tUwsvAMqVcMdh--
