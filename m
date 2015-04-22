From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_gre: use netdev_alloc_pcpu_stats()
Date: Wed, 22 Apr 2015 15:39:29 -0400 (EDT)
Message-ID: <20150422.153929.2211844092438784276.davem@davemloft.net>
References: <1429714576-23911-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423AbbDVTjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 15:39:32 -0400
In-Reply-To: <1429714576-23911-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 22 Apr 2015 16:56:16 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> The code there just open-codes the same, so use the provided macro instead.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
