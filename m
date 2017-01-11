From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vxlan: Set ports in flow key when doing route
 lookups
Date: Wed, 11 Jan 2017 16:10:10 -0500 (EST)
Message-ID: <20170111.161010.2279224715099681153.davem@davemloft.net>
References: <20170110.211004.1712612611986550798.davem@davemloft.net>
        <20170111151853.4794-1-martynas@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martynas@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755788AbdAKVKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:10:12 -0500
In-Reply-To: <20170111151853.4794-1-martynas@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martynas Pumputis <martynas@weave.works>
Date: Wed, 11 Jan 2017 15:18:53 +0000

> Otherwise, a xfrm policy with sport/dport being set cannot be matched.
> 
> Signed-off-by: Martynas Pumputis <martynas@weave.works>
> ---
> Changes in v2:
>     - Set the source port in the flow key.

Applied, thanks.
