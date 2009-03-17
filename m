From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-03-16
Date: Tue, 17 Mar 2009 13:00:09 +1100
Message-ID: <20090317130009.19e2dbd8.sfr@canb.auug.org.au>
References: <20090316231423.GA3633@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__17_Mar_2009_13_00_09_+1100_U0KhvqZyqHeRo.Xk"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090316231423.GA3633-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__17_Mar_2009_13_00_09_+1100_U0KhvqZyqHeRo.Xk
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

On Mon, 16 Mar 2009 19:14:24 -0400 "John W. Linville" <linville@tuxdriver.c=
om> wrote:
>
> The first one from Luis fixes bug 12110 at bugzilla.kernel.org.  I know
> he has worked on it for a long time and I've had several desperate users
> asking for it, so it must be good. :-)  Unfortunately, it causes some
> nasty merge errors with what is in net-next-2.6 and wireless-next-2.6.
> I created a merge-test branch in wireless-next-2.6, and the merge commit
> log goes into more detail about resolving the issue.  In short, you
> probably want to diff drivers/net/ath9k against the merge-test branch...

I resolved the conflicts as you suggested (hopefully).

Thanks.
--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__17_Mar_2009_13_00_09_+1100_U0KhvqZyqHeRo.Xk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkm/BCkACgkQjjKRsyhoI8zztQCguqAeGRTxChEEKS/Og6ton0p9
PXAAn3pPDQq4NR6HwqN6PMedITNEmWBT
=T7zP
-----END PGP SIGNATURE-----

--Signature=_Tue__17_Mar_2009_13_00_09_+1100_U0KhvqZyqHeRo.Xk--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
