From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4]bnx2x: bug fixes
Date: Mon, 03 Nov 2008 16:48:02 -0800 (PST)
Message-ID: <20081103.164802.53576998.davem@davemloft.net>
References: <1225728657.14568.9.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755392AbYKDAs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:48:27 -0500
In-Reply-To: <1225728657.14568.9.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 03 Nov 2008 18:10:57 +0200

> I'm sending this patch to the net-2.6 and not the net-next since it
> contains bug fixes that I believe should be address. Please let me know
> if you think otherwise.
> 
> 0001 Removing the PMF indication when unloading
> 0002 PCI configuration bug on big-endian
> 0003 Calling netif_carrier_off at the end of the probe
> 0004 Version Update

All applied, thanks a lot.
