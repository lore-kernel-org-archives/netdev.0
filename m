From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 6/6] bnx2x: Fix ethtool advertisement
Date: Fri, 09 Sep 2011 14:44:32 -0400 (EDT)
Message-ID: <20110909.144432.768424352540558765.davem@davemloft.net>
References: <1315392491.27750.27.camel@lb-tlvb-dmitry>
	<1315590931.2808.55.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanivr@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933104Ab1IISp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 14:45:56 -0400
In-Reply-To: <1315590931.2808.55.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 09 Sep 2011 18:55:31 +0100

> On Wed, 2011-09-07 at 13:48 +0300, Yaniv Rosner wrote:
>> Enable changing advertisement settings via ethtool.
>> 
>> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> [...]
> 
> However, I suspect these fixes will not be considered important enough
> for this release cycle, so you may need to be re-spin them for net-next.
> David?

Right, this stuff is not appropriate for the 'net' GIT tree and must
go into 'net-next'.
