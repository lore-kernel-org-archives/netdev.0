From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] be2net: Set mac addr in hw regardless
 of netif_running()
Date: Mon, 17 Aug 2009 17:49:29 -0700 (PDT)
Message-ID: <20090817.174929.02628303.davem@davemloft.net>
References: <20090817105803.GA10217@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758512AbZHRAtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 20:49:17 -0400
In-Reply-To: <20090817105803.GA10217@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Mon, 17 Aug 2009 16:28:04 +0530

> be_mac_addr_set() currently is broken when netif_running() is false.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
