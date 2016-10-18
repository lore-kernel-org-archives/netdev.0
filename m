From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet/sfc: use core min/max MTU checking
Date: Tue, 18 Oct 2016 13:54:36 -0400 (EDT)
Message-ID: <20161018.135436.1507161576613185236.davem@davemloft.net>
References: <4705a2ea-7734-b549-561c-bc7b6d8710d3@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
        jarod@redhat.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965233AbcJRRyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:54:41 -0400
In-Reply-To: <4705a2ea-7734-b549-561c-bc7b6d8710d3@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Tue, 18 Oct 2016 17:47:45 +0100

> Fixes: 61e84623 ("net: centralize net_device min/max MTU checking")
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied with Fixes tag fixed up to use a 12 character SHA1-ID.
