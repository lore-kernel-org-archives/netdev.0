From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: add XOR instruction for
 BPF JIT
Date: Mon, 24 Sep 2012 16:55:01 -0400 (EDT)
Message-ID: <20120924.165501.726184767111686709.davem@davemloft.net>
References: <20120924173450.GA28969@thinkbox>
	<1348508647.26828.1300.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932187Ab2IXUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:55:04 -0400
In-Reply-To: <1348508647.26828.1300.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 19:44:07 +0200

> On Mon, 2012-09-24 at 19:34 +0200, Daniel Borkmann wrote:
>> This patch is a follow-up for patch "filter: add XOR instruction for use
>> with X/K" that implements BPF x86 JIT parts for the BPF XOR operation.
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>> ---
>>  arch/x86/net/bpf_jit_comp.c |    9 +++++++++
>>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
