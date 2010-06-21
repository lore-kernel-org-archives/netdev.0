From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/4] caif: Bugfix not all services uses
 flow-ctrl.
Date: Sun, 20 Jun 2010 20:38:45 -0700 (PDT)
Message-ID: <20100620.203845.70216820.davem@davemloft.net>
References: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756490Ab0FUDif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 23:38:35 -0400
In-Reply-To: <1276793741-20278-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Thu, 17 Jun 2010 18:55:38 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Flow control is not used by all CAIF services.
> The usage of flow control is now part of the gerneal
> initialization function for CAIF Services.
> 
> Signed-off-by: Sjur Braendeland@stericsson.com

Applied.
