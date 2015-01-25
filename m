From: David Miller <davem@davemloft.net>
Subject: Re: [next-next PATCH 0/7] Fixes and improvements for recent
 fib_trie updates
Date: Sun, 25 Jan 2015 14:47:45 -0800 (PST)
Message-ID: <20150125.144745.630213796803038794.davem@davemloft.net>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbAYWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 17:47:45 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 22 Jan 2015 15:51:01 -0800

> While performing testing and prepping the next round of patches I found a
> few minor issues and improvements that could be made.
> 
> These changes should help to reduce the overall code size and improve the
> performance slighlty as I noticed a 20ns or so improvement in my worst-case
> testing which will likely only result in a 1ns difference with a standard
> sized trie.

Looks great, series applied, thanks Alexander.
