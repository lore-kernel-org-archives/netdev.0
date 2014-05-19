From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: fix build
Date: Sun, 18 May 2014 20:10:51 -0400 (EDT)
Message-ID: <20140518.201051.6736475563141408.davem@davemloft.net>
References: <1400434228-3971-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, mst@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbaESAKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 20:10:55 -0400
In-Reply-To: <1400434228-3971-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Sun, 18 May 2014 10:30:28 -0700

> fix build when BRIDGE_VLAN_FILTERING is not set
> 
> Fixes: 2796d0c648c94 ("bridge: Automatically manage port promiscuous mode")
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
