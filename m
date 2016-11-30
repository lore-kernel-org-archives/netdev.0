From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cgroup, bpf: remove unnecessary #include
Date: Wed, 30 Nov 2016 13:58:42 -0500 (EST)
Message-ID: <20161130.135842.1335103611336126768.davem@davemloft.net>
References: <1480529768-1954199-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, daniel@zonque.org, roszenrami@gmail.com,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933605AbcK3S6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:58:47 -0500
In-Reply-To: <1480529768-1954199-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 30 Nov 2016 10:16:08 -0800

> this #include is unnecessary and brings whole set of
> other headers into cgroup-defs.h. Remove it.
> 
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Rami Rosen <roszenrami@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Daniel Mack <daniel@zonque.org>
> ---
> Dave,
> this patch got lost somehow (marked accepted, but not in net-next).
> Resending.

Applied, thanks ALexei.
