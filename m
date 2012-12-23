From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] arp: fix a regression in arp_solicit()
Date: Sun, 23 Dec 2012 14:17:06 -0800 (PST)
Message-ID: <20121223.141706.1783471119472317669.davem@davemloft.net>
References: <1356273778-19113-1-git-send-email-xiyou.wangcong@gmail.com>
	<CA+icZUWKNAGe+jMbsonrigVZ5Sk7dDdciZn1r7oMcsAWe7i3fQ@mail.gmail.com>
	<CA+icZUXo+OQ4XZ8V588FHKrDanqwq8jR1pAHwVPjJcu+14TKeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ja@ssi.bg
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab2LWWRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 17:17:07 -0500
In-Reply-To: <CA+icZUXo+OQ4XZ8V588FHKrDanqwq8jR1pAHwVPjJcu+14TKeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Sun, 23 Dec 2012 15:58:52 +0100

> While at it you might enhance the label with "ipv4"?

That's excessive.

ARP is ipv4 and ipv4 only, in other protocols it has completely
different names.
