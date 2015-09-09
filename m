From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [GIT] Networking
Date: Wed, 9 Sep 2015 10:46:19 +0200
Message-ID: <20150909084619.GA19913@calimero.vinschen.de>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
 <CACJDEmqywG91TA7nToQgEPvnenn=FqfQE5-2Yg=GMoWghhc8=Q@mail.gmail.com>
 <CACJDEmoD_qQyKHyztz3y031k6paZW0EKuR==006nUHvjEN7evQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:51997 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbbIIIqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 04:46:23 -0400
Content-Disposition: inline
In-Reply-To: <CACJDEmoD_qQyKHyztz3y031k6paZW0EKuR==006nUHvjEN7evQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  8 22:16, Konrad Rzeszutek Wilk wrote:
> On Tue, Sep 8, 2015 at 10:14 PM, Konrad Rzeszutek Wilk
> <konrad@kernel.org> wrote:
> >
> > (Removed Linus and Andrew from the To, added Corinna ..)
>=20
> and resending again without HTML (sorry, thought I had HTML-emails
> disabled by default)
> >
> > On Thu, Sep 3, 2015 at 1:35 AM, David Miller <davem@davemloft.net> wrot=
e:
> >>
> >>
> >> Another merge window, another set of networking changes.  I've heard
> >> rumblings that the lightweight tunnels infrastructure has been voted
> >> networking change of the year.  But what do I know?
> >>
> > .. snip..
> >>
> >> Corinna Vinschen (2):
> >>       r8169: Add values missing in @get_stats64 from HW counters

Thanks, this has been reported over the weekend in
https://bugzilla.kernel.org/show_bug.cgi?id=3D104031
Strangly this didn't occur during my tests.

Looking into it...


Corinna

--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7/HaAAoJEPU2Bp2uRE+gsY0QAJORg/UuOO7KatLA1h6rk5u2
fYNjScRcSPEwoe4bzcACNO/mXPX5ejqQyi31RFWPzgcYR5ytOLvn5kPXMJbPityh
FrXCulwH7mjxV9cO+0+Z2t81imZXDWF1XJzciD6gQ5gIKYikD4T6Sz9eCxIE5Ete
VFQJA7KL2/xs+/9X9N9QWnC79GoVWZEVpcD3h8ZMOJvRnK4YmWDcCmHjOpzkadtC
73Ug4QdI8xiHPyikC8LnPv4afxMf/e3bzAjGV8LtNkFpcEplalZBAnzdoeynpKwc
+0iz5vMdFayiLezbT25yiLM+KZtUay5mGXUwyQZCIejMgN6AA7fuEa6OORu7dnaT
+jzEe6TgMUjqqTcuoPiUNt1Y6dZBj1v6NS66+W9+MwY/juKxwXQibRMgwYxW8cxc
UcKN0DQVVbMA/ruqC+deiawfZW24tYLgKGqu8AgTrD6Z73uKVLUCdooR/0vyksLc
wjsL8IvZyVYcuQkuV+A88m3ENxDxoXkdPh6eYRm1KcDDRyyO2JT1ZfZbZk+sa3Z7
W3empSCeG0HRsLAq/ivyoQcCbcmppIjP4+rAGJWnsZ0uZ7S1DAaPLBrd9qZfN9hn
hhxtY/vTgA33u/qHeeOSWT8x4EoJ7aC51bmuVV6ubmmI96jTRKFqERHQWXRTWZma
yWwFoktfgv3riAKQwIPS
=qrRK
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--
