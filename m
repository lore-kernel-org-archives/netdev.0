From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
	- add snooping functions for ARP messages
Date: Thu, 24 May 2012 07:34:12 +0200
Message-ID: <3476925.EJY4MZoOgZ@sven-desktop.home.narfation.org>
References: <201205121626.38520.lindner_marek@yahoo.de>
	<20120523214802.GA12222@pandem0nium>
	<20120523.190158.2172815395820691292.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8929942.amotMomfYv";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120523.190158.2172815395820691292.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart8929942.amotMomfYv
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 23 May 2012 19:01:58 David Miller wrote:
> It can't be all on me to answer your question, I cannot be
> the choke point.
> 
> You must lean on the entire networking developer community
> for help, otherwise it simply will not scale.

_You_ were the person that declined the pull request because _you_ wanted to 
rewrite the ARP handling. So _you_ are the person that has the insight in 
_your_ plans. Either _you_ tell us what is _your_ problem with it or _you_ 
will have to point us to a person that knows _you_.

Until now nobody stepped up (the mails were public visible to the netdev 
people). But I will ask ask Antonio to send a separate mail to netdev and 
recent arp.c commiter.

Thanks,
	Sven
--nextPart8929942.amotMomfYv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPvchUAAoJEF2HCgfBJntG0DYQALPfiJ3+OfgRRi+sy8aNVfJh
uvtKsOoF62lWJJgMKsDXI7cPbq0LG4GhJyUe3pOrtZuS+S1vLI8SIhpxOfkknGM2
mpXy0TJ2PHJXuWf/86ja4uySnBlEvtgI46hmNDLXS437WQcqE07IxsDUag3sMCgn
v9NJq2tYjf57r1RGKmwEfxMBt1Qmdyc+foUqOaNkIBYHbyOadfNkL6n1hibkSPWi
V2xcKXtI6Tqclgd7WWderz35lV3ByV8wbP5Y/ZZORG2GWmQV3dGjcC2MUG5H7z9f
uUWesu/nDH8N1lIEI7Nd+hicF1ZZkvSNku9U1TsU3uGp3PXuL1nLfqczB9RRXUN9
SSC4VpBvoCXt6GIeEkiLcEfUL7aVcjIWsyjiqpFXiK9HHM8Lc/JnOlEJOCI+rLBZ
0fwZfVxwO+VVSCCBOJyaCVGCRCCSY0u69oe1gV4hmJrGDaL3AjqUFlFdWUKMW58c
WqknQz9/x76oe86VtMk8M1ziKeyXo3Lnh7QCsVeJ73u8Qxh2I4RHcSTy6A2KROJd
6Q/0lWyeSstcJB2sUL666vkGUfDNZZXrsarizzqhk6txgKfAgDHTucgzcVHfdBKo
07HMgs493TqahLk8H+a8+LvRoVymnxeLAvDitu/+p06hNNVrfyn3VXUspmSQmoWp
Xr7pTD1hbPp4Dv1H6oIg
=dCGe
-----END PGP SIGNATURE-----

--nextPart8929942.amotMomfYv--
