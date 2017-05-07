From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2] tc: bpf: add ppc64 and sparc64 to list of
 archs with eBPF support
Date: Sat, 06 May 2017 20:23:37 -0400 (EDT)
Message-ID: <20170506.202337.1612301723689632912.davem@davemloft.net>
References: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        stephen@networkplumber.org
To: alexander@alemayhu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdEGWm4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:42:56 -0400
In-Reply-To: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Alemayhu <alexander@alemayhu.com>
Date: Sat,  6 May 2017 22:30:10 +0200

> sparc64 support was added in 7a12b5031c6b (sparc64: Add eBPF JIT., 2017-04-17)[0]
> and ppc64 in 156d0e290e96 (powerpc/ebpf/jit: Implement JIT compiler for extended BPF, 2016-06-22)[1].
> 
> [0]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=7a12b5031c6b
> [1]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=156d0e290e96
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Acked-by: David S. Miller <davem@davemloft.net>
