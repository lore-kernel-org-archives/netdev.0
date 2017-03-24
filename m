From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Fri, 24 Mar 2017 13:29:39 -0700 (PDT)
Message-ID: <20170324.132939.982617243186545861.davem@davemloft.net>
References: <20170324010227.45375-1-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964973AbdCXU3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:29:40 -0400
In-Reply-To: <20170324010227.45375-1-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 23 Mar 2017 19:02:27 -0600

> Fix copy and paste error setting rt_ttl_propagate.
> 
> Fixes: 5b441ac8784c1 ("mpls: allow TTL propagation to IP packets to be configured")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
