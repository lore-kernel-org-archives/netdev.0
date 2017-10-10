From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests: rtnetlink: test RTM_GETNETCONF
Date: Tue, 10 Oct 2017 13:15:17 -0700 (PDT)
Message-ID: <20171010.131517.2271926866543702333.davem@davemloft.net>
References: <20171010141805.19194-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934137AbdJJUPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:15:18 -0400
In-Reply-To: <20171010141805.19194-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 10 Oct 2017 16:18:05 +0200

> exercise RTM_GETNETCONF call path for unspec, inet and inet6
> families, they are DOIT_UNLOCKED candidates.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
