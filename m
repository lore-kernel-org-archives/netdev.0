From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc: bpf_jit_comp: add XOR instruction for
 BPF JIT JIT
Date: Thu, 27 Sep 2012 18:05:08 -0400 (EDT)
Message-ID: <20120927.180508.562615442422376058.davem@davemloft.net>
References: <20120924215753.GA31312@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595Ab2I0WFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:05:10 -0400
In-Reply-To: <20120924215753.GA31312@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Mon, 24 Sep 2012 23:57:54 +0200

> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF SPARC JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Looks good, applied, thanks Daniel.
