From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] PPC: bpf_jit_comp: Unify BPF_MOD | BPF_X and
 BPF_DIV | BPF_X
Date: Tue, 18 Nov 2014 13:20:42 -0500 (EST)
Message-ID: <20141118.132042.1805477418902433426.davem@davemloft.net>
References: <1416275444.1107.4.camel@concordia>
	<CAOJe8K0_u51QkKmVoVmFuGaDtKfcHP6tSWx_fgJM_erRRoQfUA@mail.gmail.com>
	<CAADnVQ+w9=aezS9uCursLS4Q40S4jcyn=5vNhoc-n5qcyrF0wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, mpe@ellerman.id.au, netdev@vger.kernel.org,
	felix@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org,
	dborkman@redhat.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbaKRSUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 13:20:48 -0500
In-Reply-To: <CAADnVQ+w9=aezS9uCursLS4Q40S4jcyn=5vNhoc-n5qcyrF0wQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 18 Nov 2014 07:37:21 -0800

> On Mon, Nov 17, 2014 at 10:58 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
>> Hi Michael,
>>
>> This patch added no new functionality so I haven't put the test
>> results (of course I ran the test suite to check the patch).
>>
>> The output :
>> [  650.198958] test_bpf: Summary: 60 PASSED, 0 FAILED
> 
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks everyone.

> btw, please don't top post.

Seriously, it's my biggest pet peeve.  It's like going to a dinner party
and eating with your feet.
