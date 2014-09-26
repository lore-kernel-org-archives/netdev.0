From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc: bpf_jit: add support for BPF_LD(X) |
 BPF_LEN instructions
Date: Fri, 26 Sep 2014 16:52:22 -0400 (EDT)
Message-ID: <20140926.165222.1706898811800695980.davem@davemloft.net>
References: <1411508171-10740-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755234AbaIZUwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:52:25 -0400
In-Reply-To: <1411508171-10740-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 23 Sep 2014 14:36:11 -0700

> BPF_LD | BPF_W | BPF_LEN instruction is occasionally used by tcpdump
> and present in 11 tests in lib/test_bpf.c
> Teach sparc JIT compiler to emit it.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks Alexei.
