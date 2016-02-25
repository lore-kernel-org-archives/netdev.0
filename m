From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf_get_stackid() and stack_trace map
Date: Thu, 25 Feb 2016 11:44:10 -0500 (EST)
Message-ID: <20160225.114410.2121629360103795168.davem@davemloft.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
	<20160220.002505.2066795907514539303.davem@davemloft.net>
	<20160225142454.GO6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, mingo@kernel.org, rostedt@goodmis.org,
	wangnan0@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcBYQoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:44:12 -0500
In-Reply-To: <20160225142454.GO6357@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 25 Feb 2016 15:24:54 +0100

> On Sat, Feb 20, 2016 at 12:25:05AM -0500, David Miller wrote:
>> From: Alexei Starovoitov <ast@fb.com>
>> Date: Wed, 17 Feb 2016 19:58:56 -0800
>> 
>> > This patch set introduces new map type to store stack traces and
>> > corresponding bpf_get_stackid() helper.
>>  ...
>> 
>> Series applied, thanks Alexei.
> 
> David, please do not apply perf patches without an ACK from me or mingo.

Sure thing.
