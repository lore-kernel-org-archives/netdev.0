From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC iproute2 doc files
Date: Mon, 2 Oct 2017 07:56:44 -0700
Message-ID: <20171002075644.10f2c4f4@xeon-e3>
References: <20170920081159.321e426b@xeon-e3>
        <20171002073109.GK2031@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/wnhYdEZkDio4KkLP3eNuKD1"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:53852 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbdJBO4r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:56:47 -0400
Received: by mail-pg0-f46.google.com with SMTP id j70so3083601pgc.10
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 07:56:47 -0700 (PDT)
In-Reply-To: <20171002073109.GK2031@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/wnhYdEZkDio4KkLP3eNuKD1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 2 Oct 2017 10:31:09 +0300
Leon Romanovsky <leon@kernel.org> wrote:

> On Wed, Sep 20, 2017 at 08:11:59AM -0700, Stephen Hemminger wrote:
> > I noticed that the iproute man pages are up to date but the LaTex docum=
entation
> > is very out of date. Rarely updated since the Linux 2.2 days.
> >
> > Either someone needs to do a massive editing job on them, or they shoul=
d just
> > be dropped. My preference would be to just drop everything in the doc/ =
directory.
> > The current versions are so old, they can't be helping. =20
>=20
> If my vote counts, I will say to drop it.
>=20
> Thanks

They are gone now in current git repo. If anyone wants them they can
resurrect them from git and revise them.

--Sig_/wnhYdEZkDio4KkLP3eNuKD1
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlnSU6wACgkQgKd/YJXN
5H4fFRAAhLIBMYGW8kueu22kkX3YjS/Xk1jG3XVNQxiQFbOJnnH3zxrK33UTOs6/
R4f/vfSkyic/I39RQRmgEOJGtOaS6AZltjkUAZDgX42GOFbWd4DOhd/gv5/Lm9hI
cd+Z6HUC81tfHhQhGU9CMu0UnDAZhZiLcpEzwtlHEvvRvoEpsk0fA1a1aHQdeBAq
+QFqiU7P9YZKydFq/KBwBtg7E0XwaEgQj/S8n8xljT/3dlz774WYcitWHlrdysxa
zZ2gCZjabV8H4p1vnJ8eI8GaGF8osIz0yxwBYmvpo3Uc1KT4ZYmxzLIf9jwMdaZh
lAf+kpD23aSbCeTzzPT0vBKo3eGJeTSzMBPtxV/AHpjycJljPEdJWOUoyWUnF8dS
ZQWCHzu6l9T3KJizr191R7D4HMwH5kM7R//6XYXsyZLPyAxrAQ4LhOeZYP5BMFJr
w5t/jW19p8aV3psYtu4RXZ+8koM8eqCKMo5yCsN6AfLQSXndSE5pbDEPTpIlxqg8
SBs4CMwqzxhT2EhfdTdjRvxFjK52v6NgPdY6cvJQEWmaDCqXExaEtvM+4puIbRYP
Xf8iBi/JCxboQt8Cy8ayRGiY/O7jR3uxivlzoAwxdYN38J2gruPNccEKxn0T89Zv
Ebn6XNS/mN4CP9uH7cNSQLaUvIVibrkOZV7rIY0s+w4F+ZQbAgs=
=u4Nm
-----END PGP SIGNATURE-----

--Sig_/wnhYdEZkDio4KkLP3eNuKD1--
