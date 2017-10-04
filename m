From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: remove __rtnl_af_unregister
Date: Wed, 04 Oct 2017 10:34:37 -0700 (PDT)
Message-ID: <20171004.103437.681341919485738572.davem@davemloft.net>
References: <20171004135849.4368-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdJDRei (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:34:38 -0400
In-Reply-To: <20171004135849.4368-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  4 Oct 2017 15:58:49 +0200

> switch the only caller to rtnl_af_unregister.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
