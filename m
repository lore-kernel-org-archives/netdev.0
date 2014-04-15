From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: use the correct max size for firmware flash
Date: Tue, 15 Apr 2014 15:16:39 -0400 (EDT)
Message-ID: <20140415.151639.709190023359801281.davem@davemloft.net>
References: <20140415185047.17386.71861.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbaDOTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 15:16:40 -0400
In-Reply-To: <20140415185047.17386.71861.stgit@build.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Tue, 15 Apr 2014 13:50:48 -0500

> The wrong max fw size was being used and causing false
> "too big" errors running ethtool -f.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>

This doesn't apply to the current net tree, please respin.
