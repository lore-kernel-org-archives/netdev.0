From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: Use correct allocation in skb_copy_ubufs
Date: Wed, 18 Jul 2012 09:45:08 -0700 (PDT)
Message-ID: <20120718.094508.251647397792903029.davem@davemloft.net>
References: <20120717120529.16840.51108.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141Ab2GRQpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:45:09 -0400
In-Reply-To: <20120717120529.16840.51108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Tue, 17 Jul 2012 17:35:29 +0530

> Use correct allocation flags during copy of user space fragments
> to the kernel. Also "improve" couple of for loops.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied to net-next
