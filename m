From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] rtlwifi: Add firmware for r8723au
Date: Tue, 03 Jun 2014 23:14:11 +0100
Message-ID: <1401833651.2412.35.camel@deadeye.wl.decadent.org.uk>
References: <1388709729-28496-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1390174519.3651.3.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uFxdRWA2LqEvmmNjulyK"
Cc: dwmw2@infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52763 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934155AbaFCWKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:10:03 -0400
In-Reply-To: <1390174519.3651.3.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uFxdRWA2LqEvmmNjulyK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-01-19 at 23:35 +0000, Ben Hutchings wrote:
> On Thu, 2014-01-02 at 18:42 -0600, Larry Finger wrote:
> > This firmware is for a driver that will soon be submitted to the kernel=
.
> > It occurs as data statements in Realtek driver rtl8723A_WiFi_linux_v4.1=
.3_6044.20121224.
> >=20
> > Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> > ---
> >  WHENCE                         |  13 +++++++++++++
> >  rtlwifi/rtl8723aufw_A.bin      | Bin 0 -> 22172 bytes
> >  rtlwifi/rtl8723aufw_B.bin      | Bin 0 -> 24118 bytes
> >  rtlwifi/rtl8723aufw_B_NoBT.bin | Bin 0 -> 19200 bytes
> >  4 files changed, 13 insertions(+)
> >  create mode 100644 rtlwifi/rtl8723aufw_A.bin
> >  create mode 100644 rtlwifi/rtl8723aufw_B.bin
> >  create mode 100644 rtlwifi/rtl8723aufw_B_NoBT.bin
> [...]
>=20
> Applied, thanks.

I just noticed that the driver in Linux 3.15 seems to ask for
rtlwifi/rtl8723aufw.bin and not rtlwifi/rtl8723aufw_A.bin.  You'll need
to change the filename on one side or the other.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-uFxdRWA2LqEvmmNjulyK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU45IuOe/yOyVhhEJAQpOtQ//fCTrLy3weegSvvE3U5JgojNe8rTHotee
8+8KRWcTsAAYSf54qQmRK6yK02XaCXC2e0Yu1B5uGodX+g2JMzoyyP+2QrhGtEkX
rUvQM4oc8NP6GFvUTz39cpYScNfoIQaxNFxFTlqqq1TsoPEx4NPfWfW86knyVcU+
WM6dO4x1nXcmkAiPSm4DaaE6+7w/RCyiUepGzvA8a6/KGTo763GLIk/oec3MGB6k
3XxhFiNw0RSOjWOEWTyOd5ShjDv50oDw874bkkQSqSpy5malPIjiwd4wk4nQxBdS
Id/C7a4qbOZ417q77j4YohQCoN5cgbG8+0tN0CNZK88MviqRVa54u9vdaF2LNA75
vWwphpImepHv43lNvK36q27iVvrTRXtuXOJZwZdHCikTGhlCP0pn1m+eZuWzwRrg
g5ApCUsXOfFpP3WVvCgEPPvk4Lr9vuwL3qQAvCh4Yi392v+nVt31DqP8LFl6VmSx
aKpT3PU/Lt3wPtNn93SndzgG+R89veyC8myGcdr/Scqmphvm6iR9eB8aP6iW+YTf
L/c71eaiZCfPdTaSD9v5S+RM0k0fssjYDUFDLjCJxyjw36YComoVCAKIZas6CH7P
5md7NbrUBAdjmO08e0/t72urJwN5M28FKhqF9rKgOvULMWzan1Hxa/ScXOYOZD3M
Imm5H2YFxjM=
=2rRW
-----END PGP SIGNATURE-----

--=-uFxdRWA2LqEvmmNjulyK--
