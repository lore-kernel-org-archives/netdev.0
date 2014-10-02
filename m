From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next PATCH V6 2/2] qdisc: dequeue bulking also pickup GSO/TSO
 packets
Date: Thu, 02 Oct 2014 16:38:51 +0200
Message-ID: <542D637B.8060906@redhat.com>
References: <20141001203345.3321.99675.stgit@dragon>  <20141001203604.3321.91746.stgit@dragon> <1412260528.16704.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbaJBOj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 10:39:28 -0400
In-Reply-To: <1412260528.16704.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2014 04:35 PM, Eric Dumazet wrote:
...
> Thanks a lot guys. I am testing this patch set today.

That's great, thanks!
