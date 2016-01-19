From: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Tue, 19 Jan 2016 05:00:35 +0000
Message-ID: <VI1PR04MB1664DFBC53F08C5CE7EBF22AE8C10@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com> <5699B211.5070602@gmail.com>
 <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <569C9CD2.10301@gmail.com>
 <VI1PR04MB1664AB0E483F01F1641059FFE8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160118151500.GD923@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160118151500.GD923-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> Sent: Monday, January 18, 2016 11:15 PM
> To: Shaohui Xie
> Cc: Sebastian Hesselbarth; Florian Fainelli; shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org;
> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-
> dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Shaohui Xie
> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
> 
> > [S.H] the fsl backplane, e.g. 10GBASE-KR, needs software to handle
> > link training, It's to train link partner, and trained by link partner
> parallel.
> >
> > But if media type is not copper, e.g. optical module, we won't need this.
> 
> So what we actually need to know is copper vs fibre?
Copper is not enough to indicate backplane, since backplane is always copper,
 but copper is not always backplane.

Thank you!
Shaohui
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
