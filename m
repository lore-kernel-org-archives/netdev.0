From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC] remove irqs_disabled warning from local_bh_enable
Date: Fri, 27 Jun 2008 12:56:05 +0200
Message-ID: <1214564165.3783.78.camel@johannes.berg>
References: <1213739834.3803.137.camel@johannes.berg>
	 <20080620155541.GC6656@elte.hu> <200806201801.09858.mb@bu3sch.de>
	 <200806201818.34904.mb@bu3sch.de> <20080623084123.GA32688@elte.hu>
	 <48647B94.5000006@pobox.com>  <20080627105329.GA11218@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kI9vewbu3uw8seEKyewH"
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Ellingsworth <david-ouYMrC2yAscdbCeoMzGj59i2O/JbrIOy@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080627105329.GA11218-X9Un+BFzKDI@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-kI9vewbu3uw8seEKyewH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-06-27 at 12:53 +0200, Ingo Molnar wrote:
> * Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org> wrote:
>=20
> > applied
>=20
> track record of 4 days of testing: the warning indeed went away and no=20
> other funnies in this area happened on that box. Thanks,

I've been running with my change for a while too now and never noticed
anything.

johannes

--=-kI9vewbu3uw8seEKyewH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIZMdAAAoJEKVg1VMiehFY6zEQAIuDWz0s26+Az4X43ONnGh9L
F2MXHUdXXQWrP7ENHNuJyfBvgjC/GDqvVS+fmILRaja6AqoY6F2Vy9Qx4vz9mVrD
h/eAF0Y4r04UqGxPzoWuiqFVIQ0UaIU6eox4hzCCmGFdbKjg4hoQntQzEEIur1yu
fsXfMCFV8Zh52NxfTEsui8USVgxQMiNxFhNvHJMJKmOBAql+wJEk8uvxWyxIe13W
PQgArDufEVQo9qkwgSPjW4x5avdyqPv9g+TR+IDNfbcuXECEnTVyI0YRInD9mlbv
BoRxJCJM2vsjOzUFDwFWH66UOyp6M2w2AiJzS4r5N3PR89DQ+cDtEL2CrTeYSY9M
Lad+FkgBhBJX/T7x/OrRGLNxvf3EOo2FXO4FtqxqeeCLDS081Ftw6i0yl6KtWnoQ
eusUjgPWZKSbEZtqdK4gRLwY2UEwVm2JzIO/wXUP07x3g1OixWGycFfXTWwrkI/f
i7FLlDYtIJVqm2mvnrSOwSswl906bVBWEq5w4SsIjE9qa7adTyHqcY/U2xQGRU1U
YgR4hf4CWzpnUKwq+G4AxzsKRKXxXkQ1PeSyCVybMZwkeieZUAbPDZeM+j7ymzz2
1bakVCj5wpsCd9eIMbsYhOPHUiBJBVvKTzbqJ21bvMN93WsSphAKyBvpKbvCfWLe
mFUkUDfQPtSwuRnU3FjJ
=30Ke
-----END PGP SIGNATURE-----

--=-kI9vewbu3uw8seEKyewH--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
