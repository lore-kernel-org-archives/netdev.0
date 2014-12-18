From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Thu, 18 Dec 2014 12:36:43 -0500 (EST)
Message-ID: <20141218.123643.1246826560311274631.davem@davemloft.net>
References: <20141216.175817.576861457076632402.davem@davemloft.net>
	<5490C73C.8010405@redhat.com>
	<20141217162749.GC28766@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbaLRRgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:36:46 -0500
In-Reply-To: <20141217162749.GC28766@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 17 Dec 2014 16:27:49 +0000

> On 12/17/14 at 12:58am, Daniel Borkmann wrote:
>> Fixes: 5fd96123ee19 ("netlink: implement memory mapped sendmsg()")
>> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Nothing to add to Daniel's excellent feedback.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable.
