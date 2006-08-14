From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: switch status codes, reason codes, and EIDs to enums
Date: Mon, 14 Aug 2006 09:40:30 -0700
Message-ID: <200608140940.35759.flamingice@sourmilk.net>
References: <200608131243.51185.flamingice@sourmilk.net> <44E02C2A.2010701@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1395818.GXd5pF386q";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:28069 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932196AbWHNQ4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 12:56:12 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E02C2A.2010701@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1395818.GXd5pF386q
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 14 August 2006 00:54, Johannes Berg wrote:
> > +	WLAN_EID_IBSS_DFS =3D 41,
> >  /* EIDs defined as part fo 11h - ends */
>
> Care to fix the two occurrences of this typo in a respun patch? (should
> be 'of' instead of 'fo')
> If you can't easily recreate that patch I'll send one after this goes in.
>
I don't really like the comments in the EID section. I would rather have th=
e=20
comments resemble the ones in ieee80211_statuscode which identifies=20
802.11b/h/g/i instead of just pointing out the ones that are 802.11h. If yo=
u=20
want to do that, that would be great, though I can probably get to it in a=
=20
few days.

Thanks,
=2DMichael Wu

--nextPart1395818.GXd5pF386q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE4KeDT3Oqt9AH4aERArvAAKDZZks7eTfWAyqCgkjB7D2XBdJGqACg0Xxq
HXQWx7psykA5YNwpKrjygm4=
=TYf+
-----END PGP SIGNATURE-----

--nextPart1395818.GXd5pF386q--
