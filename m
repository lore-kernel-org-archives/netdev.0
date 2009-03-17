From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 11:00:01 -0400
Message-ID: <49BFBAF1.3020607@athenacr.com>
References: <49B4B909.7050002@cosmosbay.com>	 <20090313.145152.121603300.davem@davemloft.net>	 <49BADE87.40407@cosmosbay.com>	 <20090313.153851.11725991.davem@davemloft.net>	 <49BED109.3020504@cosmosbay.com> <1237284716.5189.284.camel@laptop> <49BF84C0.2000808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1038 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752610AbZCQPAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 11:00:06 -0400
In-Reply-To: <49BF84C0.2000808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Sure, I should have taken more time, will repost this in a couple of hours,
> with nice CHangelogs and split patches.

One small thing: with CONFIG_IPV6=m, inet_def_readable needs to be exported,
right?

Thanks,
Brian Bloniarz
