From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6] Bundle fixes for Xen netfront / netback
Date: Wed, 17 Apr 2013 14:09:00 -0400 (EDT)
Message-ID: <20130417.140900.40803700259873477.davem@davemloft.net>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, wdauchy@gmail.com, konrad.wilk@oracle.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964924Ab3DQSJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:09:05 -0400
In-Reply-To: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 17 Apr 2013 18:41:59 +0100

> Final round of this series. All acked and ready to go in.

Does not apply to net-next.

[davem@drr net-next]$ git am --signoff bundle-4170-xen.mbox 
Applying: xen-netfront: frags -> slots in log message
Applying: xen-netfront: reduce gso_max_size to account for max TCP header
Applying: xen-netback: coalesce slots in TX path and fix regressions
error: patch failed: drivers/net/xen-netback/netback.c:1548
error: drivers/net/xen-netback/netback.c: patch does not apply
Patch failed at 0003 xen-netback: coalesce slots in TX path and fix regressions
The copy of the patch that failed is found in:
   /home/davem/src/GIT/net-next/.git/rebase-apply/patch
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Please stop wasting my time.
