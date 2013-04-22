From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V7 0/4] Bundle fixes for Xen netfront / netback
Date: Mon, 22 Apr 2013 15:41:39 -0400 (EDT)
Message-ID: <20130422.154139.1046488577191797292.davem@davemloft.net>
References: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab3DVTlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:41:40 -0400
In-Reply-To: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 22 Apr 2013 13:20:39 +0100

> This series is now rebased onto net-next.
> 
> We would also like to ask you to queue it for stable-ish tree. I can do the
> backport if necessary.

All applied, but this was a disaster.

If you want bug fixes propagated into -stable you submit them to 'net'
from the beginning.

There is no other method by which to do this.

By merging all of these changes to net-next, you will now have to get
them accepted again into 'net', and then (and only then) can you make
a request for -stable inclusion.

You are making so much extra work for me, please don't do this ever
again.
