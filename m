From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 4/5] bnx2x: Fix the race on bp->stats_pending.
Date: Sun, 09 Jan 2011 15:49:55 -0800 (PST)
Message-ID: <20110109.154955.02278258.davem@davemloft.net>
References: <1294575634.31551.18.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753177Ab1AIXtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:49:23 -0500
In-Reply-To: <1294575634.31551.18.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 9 Jan 2011 14:20:34 +0200

> Fix the race on bp->stats_pending between the timer and a LINK_UP event
> handler.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
