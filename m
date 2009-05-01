From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: add support for LAN9512 and LAN9514
Date: Fri, 01 May 2009 15:27:40 -0700 (PDT)
Message-ID: <20090501.152740.128558796.davem@davemloft.net>
References: <1241194042-6800-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com,
	vlad.lyalikov@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757754AbZEAW1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:27:45 -0400
In-Reply-To: <1241194042-6800-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri,  1 May 2009 17:07:22 +0100

> LAN9512 and LAN9514 are USB hubs with an integrated 10/100 ethernet
> controller.  Logically this looks like an ethernet controller (similar
> to LAN9500) permanently attached to one of the hub's downstream ports.
> 
> This patch adds the usb device id of the new ethernet controller to the
> smsc95xx driver.  This id is the same in both new devices.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
