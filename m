From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net 1/2] conntrack: remove obsolete sysctl
 (nf_conntrack_events_retry_timeout)
Date: Mon, 10 Oct 2016 15:57:37 +0200
Message-ID: <20161010135737.GA21057@breakpoint.cc>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org, fw@strlen.de
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58320 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751702AbcJJN7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 09:59:16 -0400
Content-Disposition: inline
In-Reply-To: <1476094704-17452-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> This entry has been removed in commit 9500507c6138.
> 
> Fixes: 9500507c6138 ("netfilter: conntrack: remove timer from ecache extension")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Florian Westphal <fw@strlen.de>
