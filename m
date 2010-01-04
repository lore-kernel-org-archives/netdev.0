From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on
 separate vlans to use arp validation
Date: Sun, 03 Jan 2010 21:19:10 -0800 (PST)
Message-ID: <20100103.211910.82043568.davem@davemloft.net>
References: <20091228152632.GA6490@gospo.rdu.redhat.com>
	<20091228.073308.112591206.davem@davemloft.net>
	<13580.1262037333@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750912Ab0ADFTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:19:07 -0500
In-Reply-To: <13580.1262037333@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 28 Dec 2009 13:55:33 -0800

> 	If Andy isn't seeing the above misbehavior, I'm fine with
> assuming it's my problem and applying the patch; if I find something
> actually wrong with the patch next week we can address it then.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Fair enough, applied to net-next-2.6, thanks.
