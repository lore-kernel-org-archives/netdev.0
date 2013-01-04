From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v3 1/3] netpoll: prepare for ipv6
Date: Fri, 04 Jan 2013 11:10:31 +0800
Message-ID: <1357269031.9955.0.camel@cr0>
References: <1357267541-6433-1-git-send-email-amwang@redhat.com>
	 <20130103.185618.1472655606309483969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab3ADDKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 22:10:46 -0500
In-Reply-To: <20130103.185618.1472655606309483969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 18:56 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Fri,  4 Jan 2013 10:45:39 +0800
> 
> > v3: fix CONFIG_IPV6=m case
> 
> You're talking about a change that isn't even present in this patch.
> 
> That's why people do "[PATCH 0/N]" cover postings with their
> patch series, to collect information like this in the most
> useful and relevent place.
> 
> Then I can check your patch set into a branch, and then do
> a merge into my master branch and make the merge commit have
> your cover letter as the commit message.
> 
> I'm not applying this series, submit it properly.
> 

Alright, will do. Sorry for my laziness.
