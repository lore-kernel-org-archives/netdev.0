From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.30 1/3] netdev: Merge UCC and gianfar MDIO bus
 drivers
Date: Wed, 04 Feb 2009 16:43:50 -0800 (PST)
Message-ID: <20090204.164350.179956029.davem@davemloft.net>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
	<1233710223-17808-2-git-send-email-afleming@freescale.com>
	<1233710223-17808-3-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761451AbZBEAny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:43:54 -0500
In-Reply-To: <1233710223-17808-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue,  3 Feb 2009 19:17:01 -0600

> The MDIO bus drivers for the UCC and gianfar ethernet controllers are
> essentially the same.  There's no reason to duplicate that much code.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
