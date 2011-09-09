From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net v2 6/6] bnx2x: Fix ethtool advertisement
Date: Fri, 09 Sep 2011 18:55:31 +0100
Message-ID: <1315590931.2808.55.camel@bwh-desktop>
References: <1315392491.27750.27.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46814 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759380Ab1IIRzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 13:55:36 -0400
In-Reply-To: <1315392491.27750.27.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-09-07 at 13:48 +0300, Yaniv Rosner wrote:
> Enable changing advertisement settings via ethtool.
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
[...]

However, I suspect these fixes will not be considered important enough
for this release cycle, so you may need to be re-spin them for net-next.
David?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
