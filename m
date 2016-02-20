From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf_get_stackid() and stack_trace map
Date: Sat, 20 Feb 2016 00:25:05 -0500 (EST)
Message-ID: <20160220.002505.2066795907514539303.davem@davemloft.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, mingo@kernel.org, rostedt@goodmis.org,
	wangnan0@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806AbcBTFZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 00:25:08 -0500
In-Reply-To: <1455767939-2700534-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 17 Feb 2016 19:58:56 -0800

> This patch set introduces new map type to store stack traces and
> corresponding bpf_get_stackid() helper.
 ...

Series applied, thanks Alexei.
