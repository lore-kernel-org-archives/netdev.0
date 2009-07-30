From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/4] bnx2x: Receive traffic that maches management
 filtering rules
Date: Thu, 30 Jul 2009 12:20:29 -0700 (PDT)
Message-ID: <20090730.122029.84313460.davem@davemloft.net>
References: <1248862804.27379.15.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbZG3TUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 15:20:22 -0400
In-Reply-To: <1248862804.27379.15.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 29 Jul 2009 13:20:04 +0300

> Due to lack of configuration, if the BMC configures the chip to pass all
> broadcast/multicast traffic to it, the host will not receive it. On top of
> fixing it, also make sure that in promiscuous mode, the host will receive the
> management traffic as well.
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
