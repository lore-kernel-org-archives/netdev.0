From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] lan78xx: Change default internal PHY ID
 to 1
Date: Thu, 27 Aug 2015 16:17:19 -0700 (PDT)
Message-ID: <20150827.161719.2292798105218631656.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D54C326@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbbH0XRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:17:20 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D54C326@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 27 Aug 2015 18:01:17 +0000

> Change default internal PHY ID to 1.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

This doesn't describe in enough details, this change.

Why is this being changed now?  How did the driver work properly with
the previous value?  If it worked previously, what negative things
could possibly happen using the new value?

You are providing zero context, and reasoning, for your change.  That
makes it impossible to review.
