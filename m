From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Tue, 5 May 2015 20:15:46 +0200
Message-ID: <20150505201546.0f998668@redhat.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
	<20150502104621.4fede885@redhat.com>
	<5544F4D7.50202@plumgrid.com>
	<20150502184625.25426091@redhat.com>
	<55450464.8060109@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228AbbEESQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 14:16:01 -0400
In-Reply-To: <55450464.8060109@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 02 May 2015 10:07:48 -0700 Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 5/2/15 9:46 AM, Jesper Dangaard Brouer wrote:
[...]
> 
> all makes sense.
> btw, I'm off the grid till Monday and it sounds like you see concrete
> spots in the code to hack this stuff in, so if you want to take over,
> please go ahead :)

Okay, I'll address my own concerns and post a patch in your name("From:")

As I would like to see this feature in pktgen, as it provides a really
easy and quick way to measure/profile changes in the ingress path...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
