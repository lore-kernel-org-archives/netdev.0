From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
Date: Mon, 15 May 2017 08:24:24 -0700
Message-ID: <20170515082424.074e472e@xeon-e3>
References: <590AF0C3.6070006@iogearbox.net>
        <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
        <590AFA8A.30602@iogearbox.net>
        <59185B16.5020107@iogearbox.net>
        <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/aq4g0Y9.69TGM3_ULLqu2nJ"; protocol="application/pgp-signature"
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35970 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965773AbdEOPY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 11:24:28 -0400
Received: by mail-pg0-f52.google.com with SMTP id x64so42338349pgd.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 08:24:27 -0700 (PDT)
In-Reply-To: <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/aq4g0Y9.69TGM3_ULLqu2nJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 15 May 2017 09:56:18 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> On 05/14/2017 03:26 PM, Daniel Borkmann wrote:
> >=20
> > David, are you still looking into fixing this? =20
>=20
> Sorry, I left the issue on the side and then forgot about it.
>=20
> Could you try the following iproute2 patch ? Thanks

The headers in iproute2 come from kernel headers.
Any changes need to be done upstream in kernel.

--Sig_/aq4g0Y9.69TGM3_ULLqu2nJ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlkZyCgACgkQgKd/YJXN
5H5UrRAAuTWiGgOhs0IWaNtBtWjcyUjKeNHofckx0q4TPEALMSxeOF0ZGHeOOKMO
FMkV/qh/jDd81FpLuFbfVWe9MKJdY7eOXCiQUhyfrd1IBMTq4iVDjRmxCjyjrpRE
+I0xyH1i31/JEHw0z3YSwKVPAJWo3Q6LGUCkubnpGl0X4rOozbXuDso34jcHtiMB
N+f04FaEmpZaDkg16kUtwPzqaJhBU7hIQ6hSuHuQsyYdKdPcnvqIpqstoP7HgRvi
pr4LXoIzNaRhdUi1mROgLb+f8nVN64sGkRLSbVrhkNuJEPGcSVcrZ2C2KrmhQk17
uaDWD7Msg91zsQeCWwQl74g4gPNQRmrB/gGm3mtWPWxoXpyTfpjEt/qJNHg/x/ez
l2wDTGX1wEOdqMVllb+7CAjO75oLVpoUyYZ1440nBxJD0rcFeVHJO0t6BP/ota2s
KmgKKcoj6tewvayMUUmYw5DK3XdiSL+WrG0l3Z+7qT6FEe5AHPQEojFLlxMoidf3
kANuisem/gGfSDuKWFf68+he38GAL+kRn524shpjYIJIszxP/r49LZUSG++/8++w
4tAVF9q2k4fOqZHLLXT+CorFjUNGvA21OWDW6QL770JWhwoU6bteCOQsoM2r10BU
fC23+wThRz/VBwfCOE6ZvqsVHQRzVr9QZJN7JnEwwTtXvVmZ4a4=
=DAG8
-----END PGP SIGNATURE-----

--Sig_/aq4g0Y9.69TGM3_ULLqu2nJ--
