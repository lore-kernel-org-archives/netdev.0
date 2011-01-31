From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/10] bnx2x: Few enhancements and styling fixes
Date: Mon, 31 Jan 2011 13:24:25 -0800 (PST)
Message-ID: <20110131.132425.28815733.davem@davemloft.net>
References: <1296483683.17181.110.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49104
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751576Ab1AaVXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 16:23:50 -0500
In-Reply-To: <1296483683.17181.110.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Mon, 31 Jan 2011 16:21:23 +0200

> The following patch series describe some link enhancements and styling fixes in bnx2x driver.
> It should not cause conflicts when integrating the net-2.6.

How can it not cause conflicts, when there is a driver version update
in yesterday's net-2.6 patch set as well as this one.

> Please consider applying it to net-next.

I've applied this series to net-next-2.6, resolving the version conflict by
hand.
