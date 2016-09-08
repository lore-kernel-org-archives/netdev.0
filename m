From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: xfrm: Change u32 sysctl entries to use
 proc_douintvec
Date: Wed, 07 Sep 2016 17:25:18 -0700 (PDT)
Message-ID: <20160907.172518.871134561524524971.davem@davemloft.net>
References: <1473206971-20131-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcIHAZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:25:19 -0400
In-Reply-To: <1473206971-20131-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue,  6 Sep 2016 18:09:31 -0600

> proc_dointvec limits the values to INT_MAX in u32 sysctl entries.
> proc_douintvec allows to write upto UINT_MAX.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

I am assuming Steffen will pick this up.
