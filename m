From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] internal BPF jit for x64 and JITed seccomp
Date: Thu, 15 May 2014 16:32:40 -0400 (EDT)
Message-ID: <20140515.163240.1029997804218599313.davem@davemloft.net>
References: <1400035847-7730-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, hpa@zytor.com,
	tglx@linutronix.de, mingo@kernel.org, chema@google.com,
	keescook@chromium.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEOUco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 16:32:44 -0400
In-Reply-To: <1400035847-7730-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 13 May 2014 19:50:44 -0700

> Internal BPF JIT compiler for x86_64 replaces classic BPF JIT.
> Use it in seccomp and in tracing filters (sent as separate patch)
> 
> Alexei Starovoitov (3):
>   net: filter: x86: split bpf_jit_compile()
>   net: filter: x86: internal BPF JIT
>   seccomp: JIT compile seccomp filter

Series applied to net-next, thanks.
