From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] net/fsl: introduce Freescale 10G MDIO driver
Date: Mon, 20 Aug 2012 00:59:24 +0000
Message-ID: <1B15080D-036C-4DBD-BB47-10EC01528866@freescale.com>
References: <1345233792-14985-1-git-send-email-timur@freescale.com>
 <20120819205724.GA27555@electric-eye.fr.zoreil.com>
 <50315A18.2040105@freescale.com>,<20120819224804.GA28300@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:28819
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751217Ab2HTA7a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 20:59:30 -0400
In-Reply-To: <20120819224804.GA28300@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Aug 19, 2012, at 6:03 PM, "Francois Romieu" <romieu@fr.zoreil.com> wrote:

> Tabi Timur-B04825 <B04825@freescale.com> :
> [...]
>> I don't see any real savings here.
> 
> xgmac_mdio_free_bus_wait could return -ETIMEDOUT and include the
> debug message.

Ok. 


> 
> -- 
> Ueimor
> 
