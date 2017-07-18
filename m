From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/5] Netfilter fixes for net
Date: Tue, 18 Jul 2017 23:11:57 +0200
Message-ID: <20170718211157.GA5832@breakpoint.cc>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
 <20170718.120340.1012556068669757824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53848 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752013AbdGRVNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 17:13:37 -0400
Content-Disposition: inline
In-Reply-To: <20170718.120340.1012556068669757824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> What about that change Eric Dumazet was talking about with Florian
> that stopped instantiating conntrack by default in new namespaces?

Seems more appropriate for -next.  If you prefer net instead, let me know
and I'll get to work.
