From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: notify uP to route ctrlq compl to rdma
 rspq
Date: Mon, 19 Jun 2017 10:53:21 -0400 (EDT)
Message-ID: <20170619.105321.265518305791781723.davem@davemloft.net>
References: <1497874248-9716-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, rajur@chelsio.com,
        stable@vger.kernel.org
To: ganeshgr@chelsio.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1497874248-9716-1-git-send-email-ganeshgr@chelsio.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon, 19 Jun 2017 17:40:48 +0530

> CC: Stable <stable@vger.kernel.org> # 4.9+

This makes no sense whatsoever.

I applied this to net-next, but:

1) Fixes destined for -stable _MUST_ be submitted to 'net' not 'net-next'.

2) Networking -stable submissions are not performed using the CC: of the
   stable alias.  It is done by asking me to queue up your change for
   the next batch of networking -stable patches I submit.
