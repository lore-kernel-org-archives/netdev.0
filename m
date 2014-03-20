From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix setsockopt in mmap examples in
 documentation
Date: Thu, 20 Mar 2014 14:12:11 -0400 (EDT)
Message-ID: <20140320.141211.792568096239010423.davem@davemloft.net>
References: <20140319215420.49a6408d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaCTSMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 14:12:18 -0400
In-Reply-To: <20140319215420.49a6408d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Wed, 19 Mar 2014 21:54:20 -0700

> The documentation for how to use netlink mmap interface is incorrect.
> The calls to setsockopt() require an additional argument.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
