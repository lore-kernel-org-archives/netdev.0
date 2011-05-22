From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] bna: Add Debugfs & Generic Netlink Interfaces to
 BNA Driver
Date: Sat, 21 May 2011 23:31:17 -0400 (EDT)
Message-ID: <20110521.233117.1332969294033493540.davem@davemloft.net>
References: <1305694621-28023-1-git-send-email-rmody@brocade.com>
	<E5313AF6F2BFD14293E5FD0F94750F86A5D76F7AC6@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab1EVDcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 23:32:22 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A5D76F7AC6@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Sat, 21 May 2011 16:06:27 -0700

> Can you please tell what is the state of this patch set? We are wondering if the patches are still under review.

The review feedback you received was that a whole new genetlink protocol
was overkill for the facilities you are providiing at the moment, so the
state of the patch moved to "changed requested"

I saw your response, and I simply disagree with it, so the patches
are staying in that state.

In any event, you don't need to ask me, check patchwork.  You make
patchwork absolutely pointless if you ask me what the state of the
patch is, and this makes a lot of extra unnecessary work for me.
Don't do it.
