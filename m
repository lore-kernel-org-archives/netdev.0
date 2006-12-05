From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with
	latest	devscape git pull..
Date: Tue, 05 Dec 2006 10:25:28 +0100
Message-ID: <1165310728.22536.1.camel@johannes.berg>
References: <45733FBF.5020800@gmail.com>
	 <1165221950.5553.49.camel@johannes.berg>  <4574662B.8000903@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-v18SG7RxbL2tDz48hO2S"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56333 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967467AbWLEJZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 04:25:41 -0500
To: Robert Martin <robertm83@gmail.com>
In-Reply-To: <4574662B.8000903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-v18SG7RxbL2tDz48hO2S
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-12-04 at 13:17 -0500, Robert Martin wrote:

> 03:00.0 0280: 14e4:4311 (rev 01)

4311 is pci-e though, iirc. Linux just shows pci-e like pci devices.


>        Capabilities: [d0] Express Legacy Endpoint IRQ 0
>                Device: Supported: MaxPayload 128 bytes, PhantFunc 0,=20
> ExtTag+
>                Device: Latency L0s <4us, L1 unlimited
>                Device: AtnBtn- AtnInd- PwrInd-
>                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported=
-
>                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
>                Link: Latency L0s <4us, L1 <64us
>                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
>                Link: Speed 2.5Gb/s, Width x1
>        Capabilities: [100] Advanced Error Reporting
>        Capabilities: [13c] Virtual Channel

looks like pci-e capabilities to me..

johannes

--=-v18SG7RxbL2tDz48hO2S
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFdTsI/ETPhpq3jKURAqh+AJwKCB3vjsbplDZ8Bi6kjPebhKJ+SgCfWSjq
1Obdkm4pnKx33GMornqM67Q=
=e/d/
-----END PGP SIGNATURE-----

--=-v18SG7RxbL2tDz48hO2S--

