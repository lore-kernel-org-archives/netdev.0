From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: fix build problems when CONFIG_IPV6=n
Date: Fri, 08 Mar 2013 11:34:24 -0500 (EST)
Message-ID: <20130308.113424.1010918003475786431.davem@davemloft.net>
References: <20130308144539.16729.15070.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933136Ab3CHQeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:34:25 -0500
In-Reply-To: <20130308144539.16729.15070.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 08 Mar 2013 09:45:39 -0500

> My last patch to solve a problem where the static/fallback labels were
> not fully displayed resulted in build problems when IPv6 was disabled.
> This patch resolves the IPv6 build problems; sorry for the screw-up.
> 
> Please queue for -stable or simply merge with the previous patch.
> 
> Reported-by: Kbuild Test Robot <fengguang.wu@intel.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied, and I'll make sure to integrate into the -stable submission
of the original patch.

Thanks.
