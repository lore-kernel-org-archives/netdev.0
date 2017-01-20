From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add bpf_probe_read_str helper
Date: Fri, 20 Jan 2017 12:09:20 -0500 (EST)
Message-ID: <20170120.120920.594824834893909165.davem@davemloft.net>
References: <20170118175549.15819-1-g.borello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@kernel.org, netdev@vger.kernel.org
To: g.borello@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752432AbdATRJW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:09:22 -0500
In-Reply-To: <20170118175549.15819-1-g.borello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>
Date: Wed, 18 Jan 2017 17:55:49 +0000

> Provide a simple helper with the same semantics of strncpy_from_unsafe():
> 
> int bpf_probe_read_str(void *dst, int size, const void *unsafe_addr)
> 
> This gives more flexibility to a bpf program.
 ...
> Signed-off-by: Gianluca Borello <g.borello@gmail.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thank you.
