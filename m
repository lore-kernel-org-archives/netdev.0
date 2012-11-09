From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ARM: net: bpf_jit_32: add XOR instruction
 for BPF JIT
Date: Fri, 09 Nov 2012 16:39:48 -0500 (EST)
Message-ID: <20121109.163948.606233183621652086.davem@davemloft.net>
References: <20121108012828.GA23143@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mgherzan@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab2KIVju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:39:50 -0500
In-Reply-To: <20121108012828.GA23143@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Thu, 8 Nov 2012 02:28:28 +0100

> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF ARM JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> Cc: Mircea Gherzan <mgherzan@gmail.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Could an ARM person please review and ACK these two patches so that
I can toss them into net-next (where the dependency is)?

Thanks!
