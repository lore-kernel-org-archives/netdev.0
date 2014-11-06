From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Thu, 06 Nov 2014 14:02:37 -0500 (EST)
Message-ID: <20141106.140237.1200539270838384865.davem@davemloft.net>
References: <CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
	<1415152068.1458.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWw4UMKZcdZfpp5D-tDfj954fbptyXJUzydgFCero6xNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKFTCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:02:43 -0500
In-Reply-To: <CAM_iQpWw4UMKZcdZfpp5D-tDfj954fbptyXJUzydgFCero6xNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 6 Nov 2014 10:05:41 -0800

> On Tue, Nov 4, 2014 at 5:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2014-11-04 at 17:25 -0800, Cong Wang wrote:
>>
>>> Seriously, think about why it should when it's just cleanup's, be practical.
>>
>> I seriously ask you to not do cleanups then.
> 
> Apparently you didn't say this when the following commits got accepted:

I very strongly encourage you to not go arguing down this road.

The issues with your submissions is the amount of churn as well as the
terseness of explanations.
