From: Madalin-Cristian Bucur <madalin.bucur-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH] dt-bindings: net: move FMan binding
Date: Thu, 25 May 2017 12:57:26 +0000
Message-ID: <AM5PR0402MB2691006D3DD1CEB8744EF8F4ECFF0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1494855398-26215-1-git-send-email-madalin.bucur@nxp.com>
 <20170515.103048.248884533404807350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org" <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
        "benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org" <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        "paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org" <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
        "mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org" <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
        "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170515.103048.248884533404807350.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Monday, May 15, 2017 5:31 PM
> Subject: Re: [PATCH] dt-bindings: net: move FMan binding
>=20
> From: Madalin Bucur <madalin.bucur-3arQi8VN3Tc@public.gmane.org>
> Date: Mon, 15 May 2017 16:36:38 +0300
>=20
> > Besides the PPC SoCs, the QorIQ DPAA FMan is also present on ARM SoCs,
> > moving the device tree binding document into the bindings/net folder.
> >
> > Signed-off-by: Madalin Bucur <madalin.bucur-3arQi8VN3Tc@public.gmane.org>
>=20
> What tree is this targetted at for merging?

I hope Rob Herring will take this into his tree, it's a device tree binding
change.=20

Thanks,
Madalin
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
