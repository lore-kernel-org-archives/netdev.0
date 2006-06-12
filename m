From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net.ipv4.ip_autoconfig sysctl removal
Date: Sun, 11 Jun 2006 21:21:00 -0700 (PDT)
Message-ID: <20060611.212100.90120929.davem@davemloft.net>
References: <20060605105831.6a314086@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36056
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750744AbWFLEUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 00:20:54 -0400
To: shemminger@osdl.org
In-Reply-To: <20060605105831.6a314086@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 5 Jun 2006 10:58:31 -0700

> The sysctl net.ipv4.ip_autoconfig is a legacy value that is not used.
> Can it finally go in 2.6.18 or do we need to go through the whole 
> feature-removal process?
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I think killing this on in 2.6.18 is ok, applied.

Thanks.
