From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: MTU for FCoE L2 ring
Date: Sun, 06 Feb 2011 11:21:08 -0800 (PST)
Message-ID: <20110206.112108.59675654.davem@davemloft.net>
References: <1296996562.16759.9.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753594Ab1BFTUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 14:20:33 -0500
In-Reply-To: <1296996562.16759.9.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 6 Feb 2011 14:49:22 +0200

> Always configure an FCoE L2 ring with a mini-jumbo MTU size (2500).
> To do that we had to move the rx_buf_size parameter from per
> function level to a per ring level.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
