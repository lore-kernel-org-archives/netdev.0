From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/4] bnx2x: WoL only with current MAC address
Date: Thu, 30 Jul 2009 12:29:11 -0700 (PDT)
Message-ID: <20090730.122911.18448240.davem@davemloft.net>
References: <1248862810.27379.17.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032AbZG3T3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 15:29:04 -0400
In-Reply-To: <1248862810.27379.17.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 29 Jul 2009 13:20:10 +0300

> In some cases with 57711E, depending on the functions unload sequence, other
> functions MAC address could have been used to wake the system as well. Make sure
> to block all but the current function if WoL is required by changing the mode
> to single function WoL.
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
