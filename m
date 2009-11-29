From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/12] sfc: Always start Falcon using the XMAC
Date: Sat, 28 Nov 2009 23:59:19 -0800 (PST)
Message-ID: <20091128.235919.211261165.davem@davemloft.net>
References: <1259422500.3709.5.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753768AbZK2H7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 02:59:13 -0500
In-Reply-To: <1259422500.3709.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:35:00 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> The strap bits are only important on Falcon A and all production
> boards using it have fixed-speed 10G PHYs.
> 
> Replace dummy MAC operations with default MAC operations.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
