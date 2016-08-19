From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] BPF helper improvements and cleanups
Date: Thu, 18 Aug 2016 23:50:30 -0700 (PDT)
Message-ID: <20160818.235030.2237617745255981437.davem@davemloft.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752380AbcHSGub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:50:31 -0400
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 18 Aug 2016 01:00:37 +0200

> This set adds various improvements to BPF helpers, a cleanup to use
> skb_pkt_type_ok() helper, addition of bpf_skb_change_tail(), a follow
> up for event output helper and removing ifdefs around the cgroupv2
> helper bits. For details please see individual patches.
> 
> The set is based against net-next tree, but requires a merge of net
> into net-next first.

I'm pretty sure I did the correct merge, so applied, thanks!
