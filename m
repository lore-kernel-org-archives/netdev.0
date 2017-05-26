From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH v3 1/2] net: phy: Add Cortina CS4340 driver (fwd)
Date: Fri, 26 May 2017 14:35:21 +0000
Message-ID: <DB5PR04MB12407EC01CDDA84D69A81F1FEAFC0@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <alpine.DEB.2.20.1705261631020.2950@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "andrew@lunn.ch" <andrew@lunn.ch>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kbuild-all@01.org" <kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1705261631020.2950@hadrien>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Julia Lawall [mailto:julia.lawall@lip6.fr]
> Sent: Friday, May 26, 2017 5:32 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: andrew@lunn.ch; f.fainelli@gmail.com; netdev@vger.kernel.org;
> devicetree@vger.kernel.org; linux-kernel@vger.kernel.org; kbuild-all@01.o=
rg
> Subject: Re: [PATCH v3 1/2] net: phy: Add Cortina CS4340 driver (fwd)
>=20
> The u32 values on lines 73 and 79 will not be less than 0.

Will change to int for proper error checking.

Thanks!
Bogdan P.
