From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove unused neigh parameter from
 ndisc functions
Date: Thu, 24 Sep 2015 12:26:19 -0700 (PDT)
Message-ID: <20150924.122619.120656282642535080.davem@davemloft.net>
References: <90e3945ff85b61be6d2ddf579ba02c45a20456a7.1442941029.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbIXT0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:26:20 -0400
In-Reply-To: <90e3945ff85b61be6d2ddf579ba02c45a20456a7.1442941029.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 22 Sep 2015 18:57:13 +0200

> Since commit 12fd84f4383b1 ("ipv6: Remove unused neigh argument for
> icmp6_dst_alloc() and its callers."), the neigh parameter of ndisc_send_na
> and ndisc_send_ns is unused.
> 
> CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Also applied, thanks.
