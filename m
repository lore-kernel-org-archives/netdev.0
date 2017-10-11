From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Rewrite some existing functionality
Date: Wed, 11 Oct 2017 15:22:59 -0700 (PDT)
Message-ID: <20171011.152259.969926721717992984.davem@davemloft.net>
References: <1507695456-17051-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdJKWXA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 18:23:00 -0400
In-Reply-To: <1507695456-17051-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue, 10 Oct 2017 22:17:29 -0600

> This series fixes some of the broken rmnet functionality.
> Bridge mode is re-written and made useable and the muxed_ep is converted to hlist.
> 
> Patches 1-5 are cleanups in preparation for these changes.
> Patch 6 does the hlist conversion.
> Patch 7 has the implementation of the rmnet bridge mode.

Series applied, thank you.
