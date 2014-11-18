From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice: Neaten includes and forward
 declarations
Date: Tue, 18 Nov 2014 15:48:31 -0500 (EST)
Message-ID: <20141118.154831.22639502436697791.davem@davemloft.net>
References: <1416091109.5912.32.camel@perches.com>
	<20141116.154923.1364136096942964102.davem@davemloft.net>
	<1416176491.24600.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbaKRUse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:48:34 -0500
In-Reply-To: <1416176491.24600.3.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 16 Nov 2014 14:21:31 -0800

> Use the appropriate #include path for neighbour.h and
> add device.h which was indirectly #included by dmaengine.h
> 
> Remove unnecessary forward declaration of struct device;
> 
> Add comments for other forward struct declarations.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This no longer applies to net-next, please respin.

Thanks.
