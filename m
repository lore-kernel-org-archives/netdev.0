From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/15] Netfilter updates for net-next
Date: Thu, 20 Aug 2015 14:48:44 -0700 (PDT)
Message-ID: <20150820.144844.1054207553671640533.davem@davemloft.net>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 19 Aug 2015 21:18:16 +0200

> The following patchset contains Netfilter updates for your net-next tree, they
> are:

This doesn't pull cleanly, I get a couple of conflicts:

[davem@localhost net-next]$ git pull --no-ff git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git
remote: Counting objects: 195, done.        
remote: Compressing objects: 100% (195/195), done.        
remote: Total 195 (delta 121), reused 0 (delta 0)        
Receiving objects: 100% (195/195), 211.81 KiB | 0 bytes/s, done.
Resolving deltas: 100% (121/121), done.
>From git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
 * branch            HEAD       -> FETCH_HEAD
Auto-merging net/netfilter/xt_CT.c
CONFLICT (content): Merge conflict in net/netfilter/xt_CT.c
Auto-merging net/netfilter/nf_synproxy_core.c
CONFLICT (content): Merge conflict in net/netfilter/nf_synproxy_core.c
Auto-merging net/netfilter/nf_conntrack_core.c
CONFLICT (content): Merge conflict in net/netfilter/nf_conntrack_core.c
Automatic merge failed; fix conflicts and then commit the result.

Please fix this up and resubmit your pull request, thanks!
