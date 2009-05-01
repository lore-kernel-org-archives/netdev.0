From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: configure LED outputs
Date: Fri, 01 May 2009 15:27:33 -0700 (PDT)
Message-ID: <20090501.152733.110999110.davem@davemloft.net>
References: <1241192811-6429-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com,
	vlad.lyalikov@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753143AbZEAW1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:27:41 -0400
In-Reply-To: <1241192811-6429-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri,  1 May 2009 16:46:51 +0100

> SMSC LAN9500 has dual purpose GPIO/LED pins, and by default at power-on
> these are configured as GPIOs.  This means that if LEDs are fitted they
> won't ever light.
> 
> This patch sets them to be LED outputs for speed, duplex and
> link/activity.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
