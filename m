From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] selftests: rtnetlink: try concurrent
 change of ifalias
Date: Wed, 04 Oct 2017 10:35:12 -0700 (PDT)
Message-ID: <20171004.103512.131703800849367140.davem@davemloft.net>
References: <20171004142259.13235-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdJDRfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:35:12 -0400
In-Reply-To: <20171004142259.13235-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  4 Oct 2017 16:22:59 +0200

> to make sure this is serialized correctly.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  change since v1:
>  Eric points out 'wait' blocks for all current children, so no need
>  for another loop.

Applied.
