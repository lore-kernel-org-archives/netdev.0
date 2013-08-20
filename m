From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/19] Netfilter/IPVS updates for net-next
Date: Tue, 20 Aug 2013 13:40:49 -0700 (PDT)
Message-ID: <20130820.134049.661722660296186091.davem@davemloft.net>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 20 Aug 2013 12:54:32 +0200

> The following batch contains Netfilter/IPVS updates for your net-next tree.
> More specifically, they are:

Pulled, but I had to resolve a conflict in the TCP conntrack code wrt.
changing the type of a local variable to "s32" in net which I merged
into net-next the other day.

Look at the merge commit I pushed out, you'll see :-)
