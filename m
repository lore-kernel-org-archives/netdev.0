From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 08:50:44 -0400
Message-ID: <1271335844.23780.8.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>  <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
	 <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	 <1271278661.16881.1761.camel@edumazet-laptop>
	 <1271333428.23780.3.camel@bigi>
	 <s2p412e6f7f1004150532y4b13a0bfgadab3e6f2f4aecd@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:44779 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab0DOMur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:50:47 -0400
Received: by qw-out-2122.google.com with SMTP id 8so423140qwh.37
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 05:50:46 -0700 (PDT)
In-Reply-To: <s2p412e6f7f1004150532y4b13a0bfgadab3e6f2f4aecd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-15 at 20:32 +0800, Changli Gao wrote:

> For historical reason, we use Linux-2.6.18. Our company have several
> products with CPU Xen, P4, or i7. Some of them are SMP, Multi-Core and
> Multi-Threaded. 

Thanks for sharing. How much more can you say? ;-> Do you have a paper
or description of some sort somewhere?

> We use the similar mechanism like dynamic weighted
> RPS. The total throughput is increased nearly linear with the number
> of the worker threads(one worker thread per CPU).

Other than the i7 - have you tried to run rps on on the P4?

cheers,
jamal


