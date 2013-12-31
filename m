From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] tun: add the RFS support
Date: Tue, 31 Dec 2013 13:32:00 -0500 (EST)
Message-ID: <20131231.133200.1111966466957616549.davem@davemloft.net>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, edumazet@google.com,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab3LaScD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:32:03 -0500
In-Reply-To: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Sun, 22 Dec 2013 18:54:30 +0800

> Since Tom Herbert's hash related patchset was modified and got merged,
> his pachset about adding support for RFS on tun flows also need to get
> adjusted accordingly. I tried to update them, and before i will start
> to do some perf tests, i hope to get one correct code base, so it's time
> to post them out now. Any constructive comments are welcome, thanks.

Series applied to net-next, thanks.
