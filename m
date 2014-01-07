From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH 5/6] [v4] phylib: Support attaching to generic 10g driver
Date: Tue, 7 Jan 2014 07:04:35 +0000
Message-ID: <242e28ff23a8472a8e13d2f32c764374@BN1PR03MB069.namprd03.prod.outlook.com>
References: <1389060865-7143-1-git-send-email-shh.xie@gmail.com>
 <20140107.005607.716747884959539511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jg1.han@samsung.com" <jg1.han@samsung.com>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"afleming@gmail.com" <afleming@gmail.com>
To: David Miller <davem@davemloft.net>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140107.005607.716747884959539511.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 07, 2014 1:56 PM
> To: shh.xie@gmail.com
> Cc: jg1.han@samsung.com; mugunthanvnm@ti.com; f.fainelli@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Xie Shaohui-B21989;
> afleming@gmail.com
> Subject: Re: [PATCH 5/6] [v4] phylib: Support attaching to generic 10g
> driver
> 
> From: <shh.xie@gmail.com>
> Date: Tue, 7 Jan 2014 10:14:25 +0800
> 
> > -static int phy_attach_direct(struct net_device *dev, struct
> > phy_device *phydev,
> > +int phy_attach_direct(struct net_device *dev, struct phy_device
> > +*phydev,
> >  			     u32 flags, phy_interface_t interface)
> 
> Since you are changing where the open parenthesis is, you must reindent
> the arguments on the second line so that they start exactly at the first
> column after that openning parenthesis.
> 
[S.H] OK. Thank you!
Will fix it in next version.

Best Regards, 
Shaohui Xie
