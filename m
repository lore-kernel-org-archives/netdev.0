From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Detect identical
 PTR_TO_MAP_VALUE_OR_NULL registers
Date: Thu, 16 Mar 2017 11:23:41 -0700 (PDT)
Message-ID: <20170316.112341.1345233465385033369.davem@davemloft.net>
References: <c678e43377187d72c87a030ad27afbcd7748e1e3.1476812715.git.tgraf@suug.ch>
        <20161019.110942.1093696611535286858.davem@davemloft.net>
        <58CA69BF.2060402@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, jbacik@fb.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753357AbdCPSXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:23:48 -0400
In-Reply-To: <58CA69BF.2060402@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 16 Mar 2017 11:32:31 +0100

> Do you have a chance to queue this one and it's follow-up fixes
> to -stable? I checked 4.10 and they seem to have it already, but
> not 4.9 kernels.
> 
> Commits:
> 
>   6760bf2 bpf: fix mark_reg_unknown_value for spilled regs on map value
>   marking
>   a08dd0d bpf: fix regression on verifier pruning wrt map lookups
>   d2a4dd3 bpf: fix state equivalence
>   57a09bf bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers

Ok, queued up.
