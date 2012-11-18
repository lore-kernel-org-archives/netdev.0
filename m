From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] PPC: net: bpf_jit_comp: add XOR
 instruction for BPF JIT
Date: Sat, 17 Nov 2012 22:13:02 -0500 (EST)
Message-ID: <20121117.221302.2292045858181105294.davem@davemloft.net>
References: <20121108213939.GA29696@thinkbox>
	<744A32A4-3F1F-4253-9ECB-59DBCC240847@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, benh@kernel.crashing.org, netdev@vger.kernel.org
To: matt@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab2KRDNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 22:13:05 -0500
In-Reply-To: <744A32A4-3F1F-4253-9ECB-59DBCC240847@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Evans <matt@ozlabs.org>
Date: Sat, 17 Nov 2012 00:00:38 +0000

> Hi Daniel,
> 
> 
> On 08/11/2012, at 9:39 PM, Daniel Borkmann wrote:
> 
>> This patch is a follow-up for patch "filter: add XOR instruction for use
>> with X/K" that implements BPF PowerPC JIT parts for the BPF XOR operation.
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>> Cc: Matt Evans <matt@ozlabs.org>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> ---
>> Disclaimer: uncompiled and untested, since I don't have a PPC machine,
>> but it should (hopefully) integrate cleanly; impl. after PPC instruction
>> reference.
> 
> Unfortunately I can only compile and test this mentally, but it looks fine, instruction formats correct etc.  Thanks!
> 
> 
> Acked-by: Matt Evans <matt@ozlabs.org>

Applied.
