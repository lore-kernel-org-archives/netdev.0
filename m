From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Sat, 22 Nov 2014 02:24:44 -0500 (EST)
Message-ID: <20141122.022444.425003630662787798.davem@davemloft.net>
References: <20141120.182339.972861702759954603.davem@davemloft.net>
	<20141121.122615.1091044030302005883.davem@davemloft.net>
	<20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaKVHYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 02:24:50 -0500
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 22 Nov 2014 04:28:57 +0000

> 	OK, here's the next bunch.  Sorry about the delay, iov_iter.c stuff
> took most of the day (and it's not included in this pile).  Please, review.

I read over this stuff twice and this series looks fine to me.

Since this is the weekend... maybe wait until Monday for other feedback
then give me a pull request?

Thanks Al.
