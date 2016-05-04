From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] drivers: fix dev->trans_start removal fallout
Date: Wed, 04 May 2016 17:07:32 -0400 (EDT)
Message-ID: <20160504.170732.338720193451082577.davem@davemloft.net>
References: <1462395367-16704-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbcEDVHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 17:07:34 -0400
In-Reply-To: <1462395367-16704-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  4 May 2016 22:56:07 +0200

> kbuild test robot reported a build failure on s390.
> While at it, also fix missing conversion in the tilera driver.
> 
> Fixes: 9b36627acecd5792 ("net: remove dev->trans_start")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
