From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net
Date: Thu, 06 Jul 2017 14:03:27 +0100 (WEST)
Message-ID: <20170706.140327.271511080332706958.davem@davemloft.net>
References: <1499345665-7428-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdGFNDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 09:03:34 -0400
In-Reply-To: <1499345665-7428-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  6 Jul 2017 14:54:23 +0200

> The following patchset contains two Netfilter fixes for your net tree,
> they are:
> 
> 1) Fix memleak from netns release path of conntrack protocol trackers,
>    patch from Liping Zhang.
> 
> 2) Uninitialized flags field in ebt_log, that results in unpredictable
>    logging format in ebtables, also from Liping.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git
> 
> Thanks a lot!

My name is David, and how do you do?

Pulled, thanks Pablo.
