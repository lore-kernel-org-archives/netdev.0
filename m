From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next-2.6] net: Define accessors to manipulate
 QDISC_STATE_RUNNING
Date: Wed, 02 Jun 2010 03:24:23 -0700 (PDT)
Message-ID: <20100602.032423.22024663.davem@davemloft.net>
References: <1274460275.2439.469.camel@edumazet-laptop>
	<1274463643.2439.473.camel@edumazet-laptop>
	<1275472154.2725.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932381Ab0FBKYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:24:13 -0400
In-Reply-To: <1275472154.2725.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Jun 2010 11:49:14 +0200

> Define three helpers to manipulate QDISC_STATE_RUNNIG flag, that a
> second patch will move on another location.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied.
