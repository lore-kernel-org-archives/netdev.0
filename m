From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Remove unnecessary prefix from
 pr_<level>
Date: Mon, 20 Dec 2010 10:30:14 -0800 (PST)
Message-ID: <20101220.103014.226776979.davem@davemloft.net>
References: <1292522532.29894.33.camel@Joe-Laptop>
	<20101216183004.GC8404@spritelink.se>
	<1292526153.29894.37.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristian@spritelink.net, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932742Ab0LTS3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:29:45 -0500
In-Reply-To: <1292526153.29894.37.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 16 Dec 2010 11:02:33 -0800

> Remove "pktgen: " prefix string from one pr_info.
> pr_fmt adds it, so this is a duplicate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
