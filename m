From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netns: igmp: make /proc/net/{igmp,mcfilter} per
 netns
Date: Thu, 25 Dec 2008 16:42:58 -0800 (PST)
Message-ID: <20081225.164258.83837158.davem@davemloft.net>
References: <20081219142505.469589973@theryb.frec.bull.fr>
	<20081219142508.685066728@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752089AbYLZAmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:42:55 -0500
In-Reply-To: <20081219142508.685066728@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Fri, 19 Dec 2008 15:25:07 +0100

> This patch makes the followinf proc entries per-netns:
> /proc/net/igmp
> /proc/net/mcfilter
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Also applied, thanks.
