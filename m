From: Harini Katakam <harini.katakam@xilinx.com>
Subject: RE: [PATCH v2 netdev] net: phy: marvell: Limit errata to 88m1101
Date: Tue, 23 May 2017 05:49:33 +0000
Message-ID: <A00F2239C6748D4289A006FCD55C6D126F1C6183@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Daniel Walker <danielwa@cisco.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0067.outbound.protection.outlook.com ([104.47.37.67]:56600
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761246AbdEWFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:49:42 -0400
In-Reply-To: <1495495713-28374-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, May 23, 2017 4:59 AM
> To: David Miller <davem@davemloft.net>
> Cc: Daniel Walker <danielwa@cisco.com>; Harini Katakam
> <harinik@xilinx.com>; Florian Fainelli <f.fainelli@gmail.com>; netdev
> <netdev@vger.kernel.org>; Andrew Lunn <andrew@lunn.ch>
> Subject: [PATCH v2 netdev] net: phy: marvell: Limit errata to 88m1101
>=20
> The 88m1101 has an errata when configuring autoneg. However, it was
> being applied to many other Marvell PHYs as well. Limit its scope to
> just the 88m1101.
>=20
> Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e114=
5")
> Reported-by: Daniel Walker <danielwa@cisco.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Harini Katakam <harinik@xilinx.com>

Regards,
Harini
