From: Qiang Zhao <qiang.zhao@nxp.com>
Subject: RE: [PATCH] Maxim/driver: Add driver for maxim ds26522
Date: Fri, 24 Jun 2016 02:00:33 +0000
Message-ID: <AM3PR04MB11854F945F63BFF95C74AE94912E0@AM3PR04MB1185.eurprd04.prod.outlook.com>
References: <1466644185-6081-1-git-send-email-qiang.zhao@nxp.com>
 <20160623.105915.1184538161171070695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "oss@buserror.net" <oss@buserror.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0099.outbound.protection.outlook.com ([157.56.112.99]:29167
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750979AbcFXFf0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 01:35:26 -0400
In-Reply-To: <20160623.105915.1184538161171070695.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-23 at 10:59PM, David Miller wrote:
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, June 23, 2016 10:59 PM
> To: Qiang Zhao <qiang.zhao@nxp.com>
> Cc: oss@buserror.net; linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> Xiaobo Xie <xiaobo.xie@nxp.com>
> Subject: Re: [PATCH] Maxim/driver: Add driver for maxim ds26522
> 
> From: Zhao Qiang <qiang.zhao@nxp.com>
> Date: Thu, 23 Jun 2016 09:09:45 +0800
> 
> > +MODULE_DESCRIPTION(DRV_DESC);
> 
> There is no definition of DRV_DESC, so this makes it look like you didn't even
> compile this driver.

I really, really compiled this driver.
Thank you for your review and comments. I will modify it the next version.

[zhaoqiang@titan:~/upstream/linux]$ll drivers/net/wan/slic_ds26522.o
-rw-r--r-- 1 zhaoqiang klocwork 153288 Jun 22 15:48 drivers/net/wan/slic_ds26522.o
[zhaoqiang@titan:~/upstream/linux]$date
Fri Jun 24 09:42:16 CST 2016

-Zhao Qiang
BR
