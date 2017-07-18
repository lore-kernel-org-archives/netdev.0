From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter fixes for net
Date: Tue, 18 Jul 2017 14:54:31 -0700 (PDT)
Message-ID: <20170718.145431.917938736055432958.davem@davemloft.net>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
        <20170718.120340.1012556068669757824.davem@davemloft.net>
        <20170718211157.GA5832@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752831AbdGRVyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 17:54:32 -0400
In-Reply-To: <20170718211157.GA5832@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 18 Jul 2017 23:11:57 +0200

> David Miller <davem@davemloft.net> wrote:
>> What about that change Eric Dumazet was talking about with Florian
>> that stopped instantiating conntrack by default in new namespaces?
> 
> Seems more appropriate for -next.  If you prefer net instead, let me know
> and I'll get to work.

Yeah it's more on the -next side, albeit annoying.

Ok, so nevermind :)
