From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] Netfilter updates for next-net (part 2)
Date: Mon, 04 Sep 2017 15:28:30 -0700 (PDT)
Message-ID: <20170904.152830.624026284447759022.davem@davemloft.net>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753978AbdIDW2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 18:28:37 -0400
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  4 Sep 2017 22:11:02 +0200

> The following patchset contains Netfilter updates for net-next. This
> patchset includes updates for nf_tables, removal of
> CONFIG_NETFILTER_DEBUG and a new mode for xt_hashlimit. More
> specifically, they:

Pulled, thanks.

Since there wasn't much review on netdev for the NONREC stuff
I reserve the right to revert if serious objections are raised.

Thanks.
