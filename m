From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] net: udp: do not report ICMP redirects to user space
Date: Tue, 24 Sep 2013 10:17:02 -0400 (EDT)
Message-ID: <20130924.101702.809917335088042479.davem@davemloft.net>
References: <523C216C.90707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab3IXORE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 10:17:04 -0400
In-Reply-To: <523C216C.90707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 20 Sep 2013 18:20:28 +0800

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> Redirect isn't an error condition, it should leave
> the error handler without touching the socket.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied.
