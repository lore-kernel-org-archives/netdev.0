From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 29/33] sfc: Use model numbers for PHY type names
Date: Fri, 12 Dec 2008 22:07:02 -0800 (PST)
Message-ID: <20081212.220702.68636586.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125944.GC10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57118
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbYLMGHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:07:01 -0500
In-Reply-To: <20081212125944.GC10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:59:44 +0000

> Some of the PHY type names are overly generic.  Change them to include
> the model numbers of the PHYs they represent.
> 
> Correct the model number reference at the top of xfp_phy.c.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
