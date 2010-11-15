From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: Move off of deprecated I/O routines.
Date: Mon, 15 Nov 2010 10:19:35 -0800 (PST)
Message-ID: <20101115.101935.15229475.davem@davemloft.net>
References: <20101101192923.GA3176@linux-sh.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iwamatsu@nigauri.org, netdev@vger.kernel.org
To: lethal@linux-sh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756765Ab0KOSTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:19:10 -0500
In-Reply-To: <20101101192923.GA3176@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mundt <lethal@linux-sh.org>
Date: Tue, 2 Nov 2010 04:29:24 +0900

> sh_eth is the last in-tree user of the ctrl_xxx I/O routines. This simply
> converts them over to regular MMIO accesors.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

Applied.
