From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove some deadcode
Date: Fri, 31 Aug 2012 16:34:09 -0400 (EDT)
Message-ID: <20120831.163409.1833540012440209040.davem@davemloft.net>
References: <1346328105-19541-1-git-send-email-sdumitru@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: sdumitru@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859Ab2HaUeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:34:13 -0400
In-Reply-To: <1346328105-19541-1-git-send-email-sdumitru@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sorin Dumitru <sdumitru@ixiacom.com>
Date: Thu, 30 Aug 2012 15:01:45 +0300

> __ipv6_regen_rndid no longer returns anything other than 0
> so there's no point in verifying what it returns
> 
> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>

Applied to net-next, thanks.
