From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ixgbe: add missing braces
Date: Fri, 10 Aug 2012 16:51:44 -0700 (PDT)
Message-ID: <20120810.165144.343078139673530026.davem@davemloft.net>
References: <1344620114-6173-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760066Ab2HJXvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 19:51:46 -0400
In-Reply-To: <1344620114-6173-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 10 Aug 2012 10:35:14 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch adds missing braces around the 10gig link check to include the check for  KR support.
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Reported-by: Sascha Wildner <saw@online.de>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied, thanks.
