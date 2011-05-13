From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice.h: Align struct netdevices members
Date: Fri, 13 May 2011 11:07:48 -0700 (PDT)
Message-ID: <20110513.110748.48500691.davem@davemloft.net>
References: <1304998966.19586.104.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46122
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750712Ab1EMSIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:08:20 -0400
In-Reply-To: <1304998966.19586.104.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 09 May 2011 20:42:46 -0700

> Save a bit of space.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied with "sed 's/netdevices/net_device/" in Subject as
requested.

Thanks.
