From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 8/8] net/mlx4_en: Set max rate-limit for a TC
Date: Sun, 01 Apr 2012 15:39:00 -0400 (EDT)
Message-ID: <20120401.153900.772503371143539866.davem@davemloft.net>
References: <20120329.172544.1685598375831468260.davem@davemloft.net>
	<CAJZOPZ+G_FSdbnBZAGFLwu+K98xBnH5BOos7DJ8Xek5dAYG+sQ@mail.gmail.com>
	<CAJZOPZLpcDbSgdRvtcRi-WTWbA5hSeKHMy4LD1fwfJmodZNKeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938Ab2DATjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 15:39:09 -0400
In-Reply-To: <CAJZOPZLpcDbSgdRvtcRi-WTWbA5hSeKHMy4LD1fwfJmodZNKeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Sun, 1 Apr 2012 22:30:24 +0300

> On Sun, Apr 1, 2012 at 10:04 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> V5 will be also against net-next but depending on your decision maybe it can
>> still go to 3.4?
> 
> Hi Dave, I didn't see a reply from you on this question, but just made
> a comment in another thread that net-next haven't opened yet, can we
> still submit this for net (3.4) or we should wait for net-next (3.5)?

New features are never valid for the net tree, only net-next.  Therefore
your question doesn't make any sense, because it is plain as day that
a patch like this is only appropriate for net-next.
