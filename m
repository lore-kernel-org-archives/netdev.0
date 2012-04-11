From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using
 net_device.{base_addr, irq}.
Date: Tue, 10 Apr 2012 20:02:12 -0400 (EDT)
Message-ID: <20120410.200212.1031414009653598743.davem@davemloft.net>
References: <CAAAKZwu4D6QZ02gaRQ2pmF=tLyxjefu1c=H83cxAJq2TTgdxmA@mail.gmail.com>
	<20120410.193042.1153959183942458232.davem@davemloft.net>
	<CAAAKZwvRvc=6qwainJAkHCUEme+PsFY-s0PWxj9tYXwSmBcYJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab2DKADS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:03:18 -0400
In-Reply-To: <CAAAKZwvRvc=6qwainJAkHCUEme+PsFY-s0PWxj9tYXwSmBcYJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Hockin <thockin@hockin.org>
Date: Tue, 10 Apr 2012 16:39:31 -0700

> OK, so that addresses that concern. :)  Thanks.
> 
> Overall nothing in the CL stands out as bad, except for the IO vs MMIO
> BAR thing, which I can not answer with certainty any more.

If you capacity to review patches to the driver for anything other
than trivial changes is close to zero, which it appears to be, you
might consider whether you should be listed in MAINTAINERS for it any
long.  And also, therefore, whether this driver should be marked
as Maintained.
