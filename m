From: David Miller <davem@davemloft.net>
Subject: Re: oops during unregister_netdevice interface enslaved to bond -
 regression
Date: Tue, 10 May 2011 12:26:17 -0700 (PDT)
Message-ID: <20110510.122617.59686955.davem@davemloft.net>
References: <1305017672.2614.9.camel@edumazet-laptop>
	<20110510131438.GA41522@tuxmaker.boeblingen.de.ibm.com>
	<1305034619.2614.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org,
	ELELUECK@de.ibm.com, opurdila@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792Ab1EJT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:26:49 -0400
In-Reply-To: <1305034619.2614.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 May 2011 15:36:59 +0200

> [PATCH net-2.6] net: dev_close() should check IFF_UP

Applied, thanks Eric.
