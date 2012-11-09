From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] PPC: net: bpf_jit_comp: add XOR
 instruction for BPF JIT
Date: Fri, 09 Nov 2012 16:40:19 -0500 (EST)
Message-ID: <20121109.164019.1147290535167723496.davem@davemloft.net>
References: <20121108213939.GA29696@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matt@ozlabs.org, benh@kernel.crashing.org, netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388Ab2KIVkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:40:21 -0500
In-Reply-To: <20121108213939.GA29696@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Thu, 8 Nov 2012 22:39:41 +0100

> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF PowerPC JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Could a powerpc person please review these two patches so that I can
toss them into net-next (where the dependency is)?

Thanks!
