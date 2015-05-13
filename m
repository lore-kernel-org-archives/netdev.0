From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: fix in-source build of samples
 with clang
Date: Tue, 12 May 2015 23:15:42 -0400 (EDT)
Message-ID: <20150512.231542.384892550295241187.davem@davemloft.net>
References: <1431404751-18298-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934280AbbEMDPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:15:43 -0400
In-Reply-To: <1431404751-18298-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 11 May 2015 21:25:51 -0700

> From: Brenden Blanco <bblanco@plumgrid.com>
> 
> in-source build of 'make samples/bpf/' was incorrectly
> using default compiler instead of invoking clang/llvm.
> out-of-source build was ok.
> 
> Fixes: a80857822b0c ("samples: bpf: trivial eBPF program in C")
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
