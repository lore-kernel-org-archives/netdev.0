From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: use dcb_setapp to manage negotiated
 application tlvs
Date: Mon, 28 Feb 2011 12:20:04 -0800 (PST)
Message-ID: <20110228.122004.59679243.davem@davemloft.net>
References: <1298313481.24633.15.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754729Ab1B1UT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:19:28 -0500
In-Reply-To: <1298313481.24633.15.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Mon, 21 Feb 2011 20:38:01 +0200

> With this patch the bnx2x uses the generic dcbnl application tlv list
> instead of implementing its own get-app handler. When the driver is
> alerted to a change in the DCB negotiated parameters, it calls
> dcb_setapp to update the dcbnl application tlvs list making it available
> to user mode applications and registered notifiers.   
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
