From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 02/06]: Set parent classid in default qdiscs
Date: Wed, 29 Nov 2006 17:35:31 -0800 (PST)
Message-ID: <20061129.173531.108742012.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130838.22347.3990.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52199
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967802AbWK3Bfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:35:32 -0500
To: kaber@trash.net
In-Reply-To: <20061120130838.22347.3990.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:38 +0100 (MET)

> [NET_SCHED]: Set parent classid in default qdiscs
> 
> Set parent classids in default qdiscs to allow walking up the tree
> from outside the qdiscs. This is needed by the next patch.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20, thanks Patrick.
