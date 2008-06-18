From: Didier Raboud <didier-efQUOpnRmEvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with 2.6.26-rc5
Date: Wed, 18 Jun 2008 13:34:06 +0200
Message-ID: <200806181334.10654.didier@raboud.com>
References: <bug-10903-10286@http.bugzilla.kernel.org/> <Pine.LNX.4.64.0806180152410.32420@wrl-59.cs.helsinki.fi> <1213773887.3803.158.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1314852.cUizIlx1dO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?iso-8859-1?q?J=E4rvinen?= <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1213773887.3803.158.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1314852.cUizIlx1dO
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le mercredi 18 juin 2008 09:24:47 Johannes Berg, vous avez =C3=A9crit=C2=A0:
> > > > > > > > http://bugzilla.kernel.org/show_bug.cgi?id=3D10903
> > > > > > > >
> > > > > > > >            Summary: ssh connections hang with 2.6.26-rc5
>
> Andrew Prince reported a similar problem and said he bisected it  to
> davem's =EF=BB=BF608961a5eca8d3c6bd07172febc27b5559408c5d ("mac80211: Use
> skb_header_cloned() on TX path.") which made no sense to me so I marked
> the report as 'to investigate when I have more time'.
>
> > > and I got the attached "soft lockup".
>
> Attached where? I can't find it in the bug either.
>
> johannes

Hi,=20

for unknown reasons, my mail doesn't appear in the mailing list archives an=
d=20
the big attachment has visibly been stripped.

You'll find the "soft lockup" there:

http://raboud.homelinux.org/~didier/kernel/tcpdump_oops.jpg

Regards,=20

Didier
=2D-=20
Didier Raboud, proud Debian user.
CH-1802 Corseaux
didier-efQUOpnRmEvQT0dZR+AlfA@public.gmane.org

--nextPart1314852.cUizIlx1dO
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkhY8q8ACgkQwW1nnOmiePC7LACgh4PI3zxmk0J2HY8CbFShx8PP
mokAnAmpInN/FS9ZwIULX2CRP7mvJs4t
=eXTe
-----END PGP SIGNATURE-----

--nextPart1314852.cUizIlx1dO--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
