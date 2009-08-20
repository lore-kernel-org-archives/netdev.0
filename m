From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V2] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 02:30:47 -0700 (PDT)
Message-ID: <20090820.023047.86718643.davem@davemloft.net>
References: <20090819122920.37EE21728051@mail110-dub.bigfish.com>
	<20090820.022536.264747725.davem@davemloft.net>
	<4A8D1750.4000804@petalogix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, sadanan@xilinx.com
To: michal.simek@petalogix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752869AbZHTJaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:30:35 -0400
In-Reply-To: <4A8D1750.4000804@petalogix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <michal.simek@petalogix.com>
Date: Thu, 20 Aug 2009 11:28:48 +0200

> There were one bug with spinlock which John L fixed but not send to
> mainling list. :-(
> He wanted to create new v3 version. :-(.
> When he wake up, he send you that bug fix or v3 version with it.

Send a new version, I'll revert V2 from my tree as I didn't push it
out yet.
