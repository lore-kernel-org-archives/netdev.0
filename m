From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/4] be2net: implement pci shutdown handler
Date: Wed, 17 Feb 2010 13:50:54 -0800 (PST)
Message-ID: <20100217.135054.50604225.davem@davemloft.net>
References: <20100217113537.GA20272@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757320Ab0BQVui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:50:38 -0500
In-Reply-To: <20100217113537.GA20272@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 17 Feb 2010 17:05:37 +0530

> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>
 ...
> +	pci_disable_device(pdev);
> +	

Trailing whitespace which I fixed up.

Applied.
