From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/13] tg3: 5784 / 5764 DMA engine lockup fix
Date: Mon, 12 Nov 2007 21:10:21 -0800 (PST)
Message-ID: <20071112.211021.239939210.davem@davemloft.net>
References: <1194655126.5745.266.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750996AbXKMFKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:10:22 -0500
In-Reply-To: <1194655126.5745.266.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:46 -0800

> 5784 and 5764 devices lock up when the link speed is 10Mbps, the CPMU
> link speed mode is enabled, and the MAC clock is running at 1.5Mhz.  The
> fix is to run the MAC clock at faster speeds.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied, thanks!
