From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] appletalk/ddp.c: Neaten checksum function
Date: Sun, 08 Nov 2009 00:44:35 -0800 (PST)
Message-ID: <20091108.004435.225244650.davem@davemloft.net>
References: <1257366373.18982.25.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbZKHIoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:44:09 -0500
In-Reply-To: <1257366373.18982.25.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 04 Nov 2009 12:26:13 -0800

> atalk_sum_partial can now use the rol16 function in bitops.h
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
