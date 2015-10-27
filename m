From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: make tracing helpers gpl only
Date: Mon, 26 Oct 2015 21:54:04 -0700 (PDT)
Message-ID: <20151026.215404.961014883291169815.davem@davemloft.net>
References: <1445637499-11146-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, a.p.zijlstra@chello.nl, wangnan0@huawei.com,
	hekuang@huawei.com, xiakaixu@huawei.com, daniel@iogearbox.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbJ0Eh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:37:26 -0400
In-Reply-To: <1445637499-11146-1-git-send-email-ast@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 23 Oct 2015 14:58:19 -0700

> exported perf symbols are GPL only, mark eBPF helper functions
> used in tracing as GPL only as well.
> 
> Suggested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
