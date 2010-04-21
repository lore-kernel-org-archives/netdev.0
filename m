From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 21 Apr 2010 14:53:28 -0700
Message-ID: <4BCF73D8.8090603@hp.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>	<1271268242.16881.1719.camel@edumazet-laptop>	<1271271222.4567.51.camel@bigi>	<20100415.014857.168270765.davem@davemloft.net>	<1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>	<1271362581.23780.12.camel@bigi>	<n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>	<1271395106.16881.3645.camel@edumazet-laptop>	<1271424065.4606.31.camel@bigi>	<1271489739.16881.4586.camel@edumazet-laptop>	<1271525519.3929.3.camel@bigi>	<1271583573.16881.4798.camel@edumazet-laptop>	<1271590476.16881.4925.camel@edumazet-laptop>	<1271764941.3735.94.camel@bigi>	<1271769195.7895.4.camel@edumazet-laptop> <1271853570.4032.21.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:39610 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756738Ab0DUVxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 17:53:34 -0400
In-Reply-To: <1271853570.4032.21.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Let me explain my test setup (which some app types may gasp at;->):
> 
> SUT(system under test) was a nehalem single processor (4 cores, 2 SMT
> threads per core). 
> SUT runs a udp sink server i wrote (with apologies to Rick Jones[1])
 > ...
> 
> [1] I want to hump on the SUT with tons of traffic and count packets;
> too complex to do with netperf

No need to apologize,  if you like I'd be happy to discuss netperf usage tips 
offline.  That offer stands for everyone.

happy benchmarking,

rick jones
