From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add vbus_enet driver
Date: Mon, 03 Aug 2009 19:38:36 -0700 (PDT)
Message-ID: <20090803.193836.248921133.davem@davemloft.net>
References: <20090803171801.17268.93846.stgit@dev.haskins.net>
	<20090804010915.17855.2660.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: ghaskins@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbZHDCi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 22:38:27 -0400
In-Reply-To: <20090804010915.17855.2660.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory Haskins <ghaskins@novell.com>
Date: Mon, 03 Aug 2009 21:14:04 -0400

> net: Add vbus_enet driver
> 
> A virtualized 802.x network device based on the VBUS interface. It can be
> used with any hypervisor/kernel that supports the virtual-ethernet/vbus
> protocol.
> 
> Signed-off-by: Gregory Haskins <ghaskins@novell.com>

I'm fine with this, it depends upon the vbus infrastructure so
whoever pulls that in can pull this in as well:

Acked-by: David S. Miller <davem@davemloft.net>
