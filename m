From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ARM: net: bpf_jit_32: add XOR instruction
 for BPF JIT
Date: Tue, 13 Nov 2012 18:21:28 -0500 (EST)
Message-ID: <20121113.182128.474002768931513696.davem@davemloft.net>
References: <20121108012828.GA23143@thinkbox>
	<50A2D0F4.3090202@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: mgherzan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338Ab2KMXVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:21:30 -0500
In-Reply-To: <50A2D0F4.3090202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mircea Gherzan <mgherzan@gmail.com>
Date: Wed, 14 Nov 2012 00:00:04 +0100

> Am 08.11.2012 02:28, schrieb Daniel Borkmann:
>> This patch is a follow-up for patch "filter: add XOR instruction for use
>> with X/K" that implements BPF ARM JIT parts for the BPF XOR operation.
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
 ...
> Acked-by: Mircea Gherzan <mgherzan@gmail.com>

Applied, thanks for reviewing.
