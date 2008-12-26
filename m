From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns: igmp: allow IPPROTO_IGMP sockets in netns
Date: Thu, 25 Dec 2008 16:42:31 -0800 (PST)
Message-ID: <20081225.164231.125269219.davem@davemloft.net>
References: <20081219142505.469589973@theryb.frec.bull.fr>
	<20081219142508.351224256@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752151AbYLZAm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:42:28 -0500
In-Reply-To: <20081219142508.351224256@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Fri, 19 Dec 2008 15:25:06 +0100

> Looks like everything is already ready.
> 
> Required for ebtables(8) for one thing.
> 
> Also, required for ipmr per-netns (coming soon). (Benjamin)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
