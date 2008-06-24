From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15]bnx2x: add BCM57711 and new features
Date: Mon, 23 Jun 2008 20:40:28 -0700 (PDT)
Message-ID: <20080623.204028.173972007.davem@davemloft.net>
References: <1214236882.3690.43.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, gertner@broadcom.com,
	vladz@broadcom.com, wendyx@us.ibm.com, yanivr@broadcom.com,
	bhutchings@solarflare.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752063AbYFXDk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:40:29 -0400
In-Reply-To: <1214236882.3690.43.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 23 Jun 2008 19:01:21 +0300

> This is another attempt to send this patch with integrated comments.
> 
> This patch adds support for two new chips: BCM57711 and its variant the
> BCM57711E, adds new link management code, new statistics code, enhanced
> self-tests, IPv6 TSO and least but not last TPA, our hardware based LRO 
> - I would like to thank Ben Hutchings for his comments on the LRO.
> 
> Wendy Xiong from IBM contributed the PCIE EEH handling code.

Added and pushed out to net-next-2.6, thanks Eilon!
