From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: fix typo in sparc BPF JIT
Date: Fri, 06 Jun 2014 00:47:58 -0700 (PDT)
Message-ID: <20140606.004758.15128274341804343.davem@davemloft.net>
References: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbaFFHsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 03:48:01 -0400
In-Reply-To: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  5 Jun 2014 22:47:44 -0700

> fix typo in sparc codegen for SKF_AD_IFINDEX and SKF_AD_HATYPE
> classic BPF extensions
> 
> Fixes: 2809a2087cc4 ("net: filter: Just In Time compiler for sparc")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> tested with qemu-sparc64
> the patch doesn't apply cleanly to net-next, but logic is the same.

Applied to net and queued up for -stable, thanks Alexey.
