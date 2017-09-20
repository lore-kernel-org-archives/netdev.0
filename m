From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/4] bpf: add helper
 bpf_perf_event_read_value for perf event array map
Date: Wed, 20 Sep 2017 16:07:07 -0700 (PDT)
Message-ID: <20170920.160707.932591498085219317.davem@davemloft.net>
References: <20170920060935.1102268-1-yhs@fb.com>
        <20170920060935.1102268-2-yhs@fb.com>
        <20170920172651.zx4nfmj2lpgxzubq@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhs@fb.com, rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdITXHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 19:07:08 -0400
In-Reply-To: <20170920172651.zx4nfmj2lpgxzubq@hirez.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 20 Sep 2017 19:26:51 +0200

> Dave, could we have this in a topic tree of sorts, because I have a
> pending series to rework all the timekeeping and it might be nice to not
> have sfr run into all sorts of conflicts.

If you want to merge it into your tree that's fine.

But it means that any further development done on top of this
work will need to go via you as well.
