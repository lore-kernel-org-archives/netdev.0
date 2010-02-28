From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] pci: Add VPD parsing support
Date: Sun, 28 Feb 2010 00:44:03 -0800 (PST)
Message-ID: <20100228.004403.245406614.davem@davemloft.net>
References: <1267229085-21303-1-git-send-email-mcarlson@broadcom.com>
	<20100227.030831.210644479.davem@davemloft.net>
	<20100227084630.6d556003@jbarnes-piketon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, andy@greyhouse.net
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55982
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031543Ab0B1Inp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:43:45 -0500
In-Reply-To: <20100227084630.6d556003@jbarnes-piketon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Sat, 27 Feb 2010 08:46:30 -0800

> On Sat, 27 Feb 2010 03:08:31 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: "Matt Carlson" <mcarlson@broadcom.com>
>> Date: Fri, 26 Feb 2010 16:04:38 -0800
>> 
>> > This patch adds code to help parse a device's VPD.  The bnx2 and tg3
>> > network drivers are modified as an example on how to use the API.  I
>> > believe the bnx2x driver will also use this API in the future.
>> 
>> PCI folks, ok with this?
>> 
>> And if so, OK if I merge this via the net-next-2.6 tree?
> 
> Yeah, latest round looks good to me.  Thanks for doing this, Matt!
> 
> Acked-by: Jesse Barnes <jbarnes@virtuousgeek.org>

Thanks Jesse, I've added these changes to my tree.
