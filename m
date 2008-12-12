From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: SMSC LAN9420 10/100 PCI ethernet adapter
Date: Thu, 11 Dec 2008 20:56:17 -0800 (PST)
Message-ID: <20081211.205617.167964158.davem@davemloft.net>
References: <1228910201-19328-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vlad.lyalikov@smsc.com,
	ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756227AbYLLE4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 23:56:16 -0500
In-Reply-To: <1228910201-19328-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed, 10 Dec 2008 11:56:41 +0000

> This patch adds a driver for the LAN9240 PCI ethernet adapter.
> 
> Changes since initial submission:
>  - debug msg_level has been changed to use standard definitions
>  - convert to use net_device_ops
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6, thanks Steve.
