From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] bnx2x: Minor link related fixes
Date: Wed, 01 Sep 2010 10:45:24 -0700 (PDT)
Message-ID: <20100901.104524.216750458.davem@davemloft.net>
References: <1283370674.4403.131.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yaniv.rosner@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753954Ab0IARpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 13:45:07 -0400
In-Reply-To: <1283370674.4403.131.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Date: Wed, 1 Sep 2010 22:51:14 +0300

> Hi Dave,
> The following patch series is dealing with some small adaptations of the
> bnx2x link code which are required to support new HW or fixing some
> minor issues with existing HW.
> 
> Please consider applying it to net-next.

All applied, thank you.

Can you explain why 10mbit/100mbit links have to use forced link mode
and do not use autonegotiation by default?  I could understand for
10mbit but 100mbit too?
