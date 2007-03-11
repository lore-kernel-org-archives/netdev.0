From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH RESEND] zd1211rw-mac80211: changed Kconfig
Date: Sun, 11 Mar 2007 17:41:46 -0400
Message-ID: <200703111741.51440.flamingice@sourmilk.net>
References: <20070311191931.752B67B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart24976746.hzOsMpKG4z";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070311191931.752B67B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart24976746.hzOsMpKG4z
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 11 March 2007 15:19, Daniel Drake wrote:
> Changed the reference to Devicescape stack to mac80211.
>
I referred to Devicescape originally because the only other driver that had=
=20
both softmac and devicescape versions was bcm43xx, so I copied "(DeviceScap=
e=20
stack)" in order to be consistent. I would prefer that there be one patch t=
o=20
replace both instances of "(DeviceScape stack)" with "(mac80211 stack)".

=2DMichael Wu

--nextPart24976746.hzOsMpKG4z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBF9HefT3Oqt9AH4aERAsjzAJ9AkCKeYMSAQSkiEMn4GeLJMc+UxgCdHQ2x
N7/zsoiSJJLhctATMSRJ5G8=
=PNgy
-----END PGP SIGNATURE-----

--nextPart24976746.hzOsMpKG4z--
