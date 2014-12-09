From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: set correct protocol on route
 lookup
Date: Tue, 09 Dec 2014 16:01:51 -0500 (EST)
Message-ID: <20141209.160151.1816426599503963739.davem@davemloft.net>
References: <0ead411e38bc57a8971ffd9826f7bf9bfdc6ccf1.1417796557.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com,
	wenyuz@vmware.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaLIVBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:01:54 -0500
In-Reply-To: <0ead411e38bc57a8971ffd9826f7bf9bfdc6ccf1.1417796557.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri,  5 Dec 2014 17:24:28 +0100

> Respect what the caller passed to ovs_tunnel_get_egress_info.
> 
> Fixes: 8f0aad6f35f7e ("openvswitch: Extend packet attribute for egress tunnel info")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
