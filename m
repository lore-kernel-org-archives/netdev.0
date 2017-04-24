From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH net 0/3] net: dsa: b53: BCM58xx devices fixes
Date: Mon, 24 Apr 2017 14:32:49 -0700
Message-ID: <878tmpij9a.fsf@eliezer.anholt.net>
References: <20170424212723.15407-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: andrew@lunn.ch, vivien.didelot@savoifairelinux.com,
        jon.mason@broadcom.com, Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anholt.net ([50.246.234.109]:36796 "EHLO anholt.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S977617AbdDXVc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 17:32:56 -0400
In-Reply-To: <20170424212723.15407-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Florian Fainelli <f.fainelli@gmail.com> writes:

> Hi David,
>
> This patch series contains fixes for the 58xx devices (Broadcom Northstar
> Plus), which were identified thanks to the help of Eric Anholt.

This series is:

Tested-by: Eric Anholt <eric@anholt.net>

Thanks for all your help debugging this, Florian!  I'll send out my DT
changes now.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlj+bwEACgkQtdYpNtH8
nuiogRAAk/L37zGVScqzT4WGy8kIMBTrjYfe5UEahTJsfY1IVd7eZcucR7q7zxFd
BJ2GHfcpVl0+dwdaWZZAnK5OsizRkwYFpbo86YYvbloDX7k3zcgGT1bVKuZLMJvO
h/EfdvssA4OQlWuYJBSZGnALpoYbn3YX81TBWr38mUc1a/nmmELT9M8II/3o09Wl
bOFBSxbptsaqKRXbN4e3h9Egnrp14hYpHWDf/Gxg4JCnNHUBh+0uOpW1NK9A021D
2ahuYwDGHtpmnfHX0bynAo8T2jZ7wI6nj4SXMtn5gpKSzAMmScH1sa8J4TRakisj
j9MmEvYu2aXi7UXpHwK+reQeG85/Z1T6wcDSheBEJztNDq++RCmcr8COl6IFZW9+
aDJUajRFob0OZtePeo9wLN5LbbGFGOTT4DU2xEJvqm8nxtt7HfLEejzEI5AmmLF8
ZFg4gioYqztDZpOUDnnBstVfM8NBrYM+dJTKWSymF6TOr3L0Bo2bAn4/gnG3lc3l
zJlFlnCIYUkpX8505+wEyCbITze+DRRXCdDBXfjVmke3dHuucfv9Z+475CcNi0jG
VK6Oe63QzMi+4QvfpieJRa2yaaJLKLenLjgXOV04xyOTpao25HDgMXFMl3OwXxoh
9Tggoy3THkmEMvD0odIModFoY3MJf7U54xA7UZ7Abd9W61aSgy0=
=mXfn
-----END PGP SIGNATURE-----
--=-=-=--
