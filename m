From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7][BNX2]: Fix 5706 serdes link down bug.
Date: Tue, 29 Jan 2008 21:33:39 -0800 (PST)
Message-ID: <20080129.213339.193699949.davem@davemloft.net>
References: <1201652325.19087.10.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752088AbYA3FdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 00:33:21 -0500
In-Reply-To: <1201652325.19087.10.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 29 Jan 2008 16:18:45 -0800

> [BNX2]: Fix 5706 serdes link down bug.
> 
> 1. Correct the MII expansion serdes control register definition.
> 2. Check an additional RUDI_INVALID bit when determining 5706S link.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
