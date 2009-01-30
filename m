From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] sfc: SFT9001: Enable robust link training
Date: Fri, 30 Jan 2009 14:09:04 -0800 (PST)
Message-ID: <20090130.140904.37637243.davem@davemloft.net>
References: <20090129.170811.135213740.davem@davemloft.net>
	<20090130034810.GC15266@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46542
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZA3WJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:09:06 -0500
In-Reply-To: <20090130034810.GC15266@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 30 Jan 2009 03:48:10 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Enable a firmware option that appears to be necessary for reliable
> operation.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

I applied all of these patches but:

1) When you get changes written by other people, such as
   Steve Hodgson here and in the next few patches, you need
   to get Signed-off-by lines from them too.

2) Outside of the merge window I do not want to see totally
   irrelevant stuff like PHY loopback fixes.

   Those kinds of fixes are totally inappropriate at this time.

You have been warned :-)
