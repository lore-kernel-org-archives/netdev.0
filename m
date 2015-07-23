From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH] net/mdio: fix mdio_bus_match for c45 PHY
Date: Thu, 23 Jul 2015 02:41:33 +0000
Message-ID: <BLUPR03MB1475EAF589E991F42CA35D70E2820@BLUPR03MB1475.namprd03.prod.outlook.com>
References: <1437127639-48082-1-git-send-email-shh.xie@gmail.com>
 <20150721.001704.649972038239229587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0122.outbound.protection.outlook.com ([207.46.100.122]:55904
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753465AbbGWC4N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 22:56:13 -0400
In-Reply-To: <20150721.001704.649972038239229587.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, July 21, 2015 3:17 PM
> To: shh.xie@gmail.com
> Cc: netdev@vger.kernel.org; Xie Shaohui-B21989
> Subject: Re: [PATCH] net/mdio: fix mdio_bus_match for c45 PHY
> 
> From: <shh.xie@gmail.com>
> Date: Fri, 17 Jul 2015 18:07:19 +0800
> 
> > From: Shaohui Xie <Shaohui.Xie@freescale.com>
> >
> > We store c45 PHY's id information in c45_ids, so it should be used to
> > check the matching between PHY driver and PHY device for c45 PHY.
> >
> > Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Applied, thanks.
As mentioned, the patch was applied, but it does not merged, seems it was missed.

Thanks.
Shaohui
