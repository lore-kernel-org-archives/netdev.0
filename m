From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: brcm WARN() on v3.7.2
Date: Sat, 26 Jan 2013 14:56:22 +0200
Message-ID: <20130126125622.GA9542@arwen.pp.htv.fi>
References: <20130125202355.GA4846@arwen.pp.htv.fi>
 <5103B595.8060805@broadcom.com>
Reply-To: <balbi-l0cyMroinI0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Cc: <balbi-l0cyMroinI0@public.gmane.org>, Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5103B595.8060805-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, Jan 26, 2013 at 11:53:09AM +0100, Arend van Spriel wrote:
> On 01/25/2013 09:23 PM, Felipe Balbi wrote:
> > Hi folks,
> >=20
> > I'm running Fedora 18 with v3.7.2 on her MacBookAir 11" and it
> > turns out that brcm is acting out, see below full dmesg. Any tips ?
> > Is this fixed already ?
>=20
> Thanks, Felipe
>=20
> The warning itself means flush timed out, ie. not all outstanding
> packets could be transmitted. It does not necessarily mean the driver
> is failing. So do you have any connectivity issues after the warning
> has occurred?

not really, just thought I'd mention it ;-)

--=20
balbi

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRA9J1AAoJEIaOsuA1yqREa0QP/RSbSILVRzFoVIXaUIYP+CeO
o1qHywxFhz5fGNYYCa0FTh1MPcIcHi5wMpBR5b4jBIL4EBl4whSY2ULWxl1RijZR
YHQrs1Jz0ZTkP1VYWySV0GuC/Mz3slKc6l+b69koc5Z8sKvh8TFIIO3FPcJJbkrj
vG0OKW5iRU+3zdE80HEQXkjS1FsvSdZfGYKyVR2jT9tAeS0/nOYa5Muy6tWWWt3l
fAv0DHa2jHNBWV2860Gdqf8T/lTAEFHgFNR7yxYTDCEqIhpHCRmdUVkTda68hWOS
H6V4JlxhMD1Y5xiFNY6pkBraRstpLU1g087ReF6ZP1Ga8WFfBHx+uXVsJwgzexrc
6ftGu1gMQsO/Dn0jBVJspaPOcf0b6FV2TrJHfUQ+cdmb4enmqRhAbBb1Eedulbu2
rsA9jYpW/Eum5/4O1CaracTGxNRpzoL+Of6H7t805LylWTvV7bqo9z26Cm2EmYwX
Wr0OO1Ml8e90vBJlXzDQ6ssfzyGhpdlc9g3k8Xm0X+pg+E4Uhbw9Ha2ARude/1rq
I6eyMObVWqHTJjfWDAiRHNouJkso0bokcjbxIew6bAlqt4BY72/34ysbIbsZlqem
eBzNx7Dm1Wo9AyXj4v9e0TrRz046ntkdjxi1mRhurYtduZC70f3OMGBU7QnoA974
OwOlXiJPTkSKBmvEQ7EW
=Uac3
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
