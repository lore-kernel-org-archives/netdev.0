From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] SMSC LAN75xx USB gigabit ethernet adapter driver
Date: Mon, 15 Mar 2010 15:40:04 -0700 (PDT)
Message-ID: <20100315.154004.24077458.davem@davemloft.net>
References: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43094
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932386Ab0COWjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:39:42 -0400
In-Reply-To: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed, 10 Mar 2010 18:26:53 +0000

> This patchset adds a driver for SMSC's new LAN7500 USB 2.0 to Gigabit
> Ethernet controller.

Please combine all of these changes into one big commit that simply
adds the new driver.  It's just commit noice the way you have
submitted this currently.

Thanks.

