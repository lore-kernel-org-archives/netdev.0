From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 1/2] PPC: net: bpf_jit_comp: add XOR
 instruction for BPF JIT
Date: Sat, 10 Nov 2012 12:50:58 +1100
Message-ID: <1352512258.23412.5.camel@pasglop>
References: <20121108213939.GA29696@thinkbox>
	 <20121109.164019.1147290535167723496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, matt@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59193 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057Ab2KJBvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 20:51:19 -0500
In-Reply-To: <20121109.164019.1147290535167723496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 16:40 -0500, David Miller wrote:
> From: Daniel Borkmann <dxchgb@gmail.com>
> Date: Thu, 8 Nov 2012 22:39:41 +0100
> 
> > This patch is a follow-up for patch "filter: add XOR instruction for use
> > with X/K" that implements BPF PowerPC JIT parts for the BPF XOR operation.
> > 
> > Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> 
> Could a powerpc person please review these two patches so that I can
> toss them into net-next (where the dependency is)?

Sure, travelling right now, will try to find somebody or will do it
myself some time next week.

Cheers,
Ben.
