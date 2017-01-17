From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Tue, 17 Jan 2017 00:11:11 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
References: <20170115172150.GC5643@lunn.ch>
        <1484571579.3374.4.camel@163.com>
        <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
 <20170116.165401.1642553705400599921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cugyly@163.com" <cugyly@163.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:61366 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750728AbdAQALP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 19:11:15 -0500
In-Reply-To: <20170116.165401.1642553705400599921.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 17, 2017 5:54 AM
> To: f.fainelli@gmail.com
> Cc: cugyly@163.com; andrew@lunn.ch; netdev@vger.kernel.org; YUAN Linyu
> Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
> 
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 16 Jan 2017 12:22:16 -0800
> 
> >
> > So why not add support in ethtool for reading PHY registers if you need
> > it? There are handful of PHY "things" in ethtool, such as reading
> > counters, configuring downshift etc., adding support for dumping
> > registers does not sound out of space.
Thanks, I will try this direction.
> 
> Agreed.
