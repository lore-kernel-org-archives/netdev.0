From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH v3 2/2] dt-bindings: net: Add Cortina device tree bindings
Date: Fri, 26 May 2017 13:41:13 +0000
Message-ID: <DB5PR04MB1240819AA151E750D32634EEEAFC0@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495785519-1468-3-git-send-email-bogdan.purcareata@nxp.com>
 <20170526133554.GD31389@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526133554.GD31389@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, May 26, 2017 4:36 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org;
> devicetree@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v3 2/2] dt-bindings: net: Add Cortina device tree
> bindings
>=20
> > +		cs4340_phy@1 {
> > +			compatible =3D "ethernet-phy-id13e5.1002";
> > +			reg =3D <0x10>;
>=20
> The @1 and the reg value should be the same. Please change it to
> cs4340_phy@10.

Will do, thanks!
Bogdan
