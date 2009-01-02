From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc requeue stats
Date: Fri, 2 Jan 2009 13:02:07 +0000
Message-ID: <20090102130206.GA4450@ff.dom.local>
References: <20081226.142923.63754891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: donash4@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:37454 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756148AbZABNCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 08:02:15 -0500
Content-Disposition: inline
In-Reply-To: <20081226.142923.63754891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-12-2008 23:29, David Miller wrote:
> From: "Don Ash" <donash4@gmail.com>
> Date: Sat, 27 Dec 2008 00:14:03 +0200
> 
>> Is there a way to see q->qstats.requeues statistics
>> (dev_requeue_skb()) ? I tried tc tool but it does not
>> show it...

Something like this should work: tc -s qdisc show
Otherwise more details are needed.

Jarek P.
