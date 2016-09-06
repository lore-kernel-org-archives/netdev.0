From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/29] Netfilter updates for net-next
Date: Tue, 06 Sep 2016 12:47:37 -0700 (PDT)
Message-ID: <20160906.124737.1399793113981333128.davem@davemloft.net>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  5 Sep 2016 12:58:15 +0200

> Hi David,
> 
> The following patchset contains Netfilter updates for your net-next
> tree.  Most relevant updates are the removal of per-conntrack timers to
> use a workqueue/garbage collection approach instead from Florian
> Westphal, the hash and numgen expression for nf_tables from Laura
> Garcia, updates on nf_tables hash set to honor the NLM_F_EXCL flag,
> removal of ip_conntrack sysctl and many other incremental updates on our
> Netfilter codebase.
> 
> More specifically, they are:
 ...
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo.
