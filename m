From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in
 skb_network_protocol()
Date: Wed, 08 May 2013 19:43:08 -0700 (PDT)
Message-ID: <20130508.194308.824826486646607687.davem@davemloft.net>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
	<20130508.131547.1016073329398924443.davem@davemloft.net>
	<CALnjE+rkpy2vC84L2koq93=ZqHe3fN_1A-09yh=ugFMXBnzM3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, amwang@redhat.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab3EICnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 22:43:12 -0400
In-Reply-To: <CALnjE+rkpy2vC84L2koq93=ZqHe3fN_1A-09yh=ugFMXBnzM3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Wed, 8 May 2013 19:32:40 -0700

> On Wed, May 8, 2013 at 1:15 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Tue,  7 May 2013 23:41:07 -0700
>>
>>> Rather than having logic to calculate inner protocol in every
>>> tunnel gso handler move it to gso code. This simplifies code.
>>>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> Cc: Cong Wang <amwang@redhat.com>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>>
>> Applied.
> 
> Hi David,
> Can you queue this patch for -stable ?

Done.
