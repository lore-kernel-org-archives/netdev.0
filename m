From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] myri10ge: update firmware to 1.4.57
Date: Sun, 09 Feb 2014 13:25:15 +0000
Message-ID: <1391952315.25202.59.camel@deadeye.wl.decadent.org.uk>
References: <1391254899-61702-1-git-send-email-hyong-youb.kim@myricom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hLtqfZzeHTA750kvCMeW"
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	Hyong-Youb Kim <hykim@myri.com>
To: Hyong-Youb Kim <hyong-youb.kim@myricom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40546 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbaBINZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 08:25:19 -0500
In-Reply-To: <1391254899-61702-1-git-send-email-hyong-youb.kim@myricom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hLtqfZzeHTA750kvCMeW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-02-01 at 03:41 -0800, Hyong-Youb Kim wrote:
> From: Hyong-Youb Kim <hykim@myri.com>
>=20
> Update firmware images for Myri10GE NICs.
>=20
> Signed-off-by: Hyong-Youb Kim <hykim@myri.com>
> ---
>  WHENCE                        |    6 +++++-
>  myri10ge_eth_big_z8e.dat      |  Bin 0 -> 378832 bytes
>  myri10ge_eth_z8e.dat          |  Bin 367464 -> 378736 bytes
>  myri10ge_ethp_big_z8e.dat     |  Bin 0 -> 389144 bytes
>  myri10ge_ethp_z8e.dat         |  Bin 377784 -> 389056 bytes
>  myri10ge_rss_eth_big_z8e.dat  |  Bin 0 -> 536192 bytes
>  myri10ge_rss_eth_z8e.dat      |  Bin 553192 -> 536176 bytes
>  myri10ge_rss_ethp_big_z8e.dat |  Bin 0 -> 545936 bytes
>  myri10ge_rss_ethp_z8e.dat     |  Bin 563592 -> 545920 bytes
>  9 files changed, 5 insertions(+), 1 deletions(-)
>  create mode 100644 myri10ge_eth_big_z8e.dat
>  create mode 100644 myri10ge_ethp_big_z8e.dat
>  create mode 100644 myri10ge_rss_eth_big_z8e.dat
>  create mode 100644 myri10ge_rss_ethp_big_z8e.dat
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-hLtqfZzeHTA750kvCMeW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUveBu+e/yOyVhhEJAQpJng//VDGyjxvAJ1uiqlbvX2GbMuDvshZyc6Dh
ZWmiv6Hx/2qqnxhZWyT0z8yHgmzLbDFC8g/zCCQ5xnkDEZW6bAR2hljxlmXBjH17
bBp/OZcG+H3rFwzLlIYVUyfP4r3W41PsAIdQW67a7eyqjqZeNiAlRjCu9/uca8Ui
uloQH21w4AVvVEU9B3o1GcXxxkbu6vmBMjXrS/Jxa9njstgWiZzVPN38H379aivR
1iX6JUdpMRt8PRU1tb8dEyO8SXvBt5cJOzmUVUyASWZPAtT+8nb7WoXyJouW064a
LibXCw9v0zVn6jzmkDhWGhheRl4FZ1OBpLAWWJ37xOCmxQvLlRxhobvDFpz2w02E
3refMpb0ElzAndZ4bDrdvsi28RwkKp2iOkpbAL47NlUSxJvCv/0ZeVi94pLfdCI+
0XgX4NuEaTb8ttREKEPvqW9wpFD6GscAQfQGyCpkIhrn2QjNmPcxwhidmVn4CCN7
c+25rK/CVTyh5bARHShTACS9U8ddr3aMkW4yL2gHaPokokD5jw5Us2pak7Ftqhfo
0D/kuVgMOua/ayR9GLNAFWLBMvWSdTFfbpAI12QxvM65Xhx9gcmTlfpC/wfC5/SR
vHa/wA3DMVOXxNtsga4/VLoEmidfI3149Xj4mil44XrefdglWKvJpg2Qj9LMnjQG
JLgKwUj2qR8=
=ADZP
-----END PGP SIGNATURE-----

--=-hLtqfZzeHTA750kvCMeW--
