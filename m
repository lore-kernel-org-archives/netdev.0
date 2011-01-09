From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/5] bnx2x: Move to D0 before clearing
 MSI/MSI-X configuration.
Date: Sun, 09 Jan 2011 15:49:50 -0800 (PST)
Message-ID: <20110109.154950.233697754.davem@davemloft.net>
References: <1294575619.31551.17.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752161Ab1AIXtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:49:18 -0500
In-Reply-To: <1294575619.31551.17.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 9 Jan 2011 14:20:19 +0200

> Move to D0 before clearing MSI/MSI-X configuration. Otherwise MSI/MSI-X
> won't be cleared.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
