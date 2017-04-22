From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: Add sparc support to tools and samples.
Date: Sat, 22 Apr 2017 16:02:46 -0400 (EDT)
Message-ID: <20170422.160246.303157283280813189.davem@davemloft.net>
References: <20170422.153846.1171688488318421720.davem@davemloft.net>
        <58FBB326.5090409@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161450AbdDVUCs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 16:02:48 -0400
In-Reply-To: <58FBB326.5090409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 22 Apr 2017 21:46:46 +0200

> On 04/22/2017 09:38 PM, David Miller wrote:
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> LGTM, thanks!
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Great, this and the sparc64 eBPF JIT are now pushed out to net-next.
