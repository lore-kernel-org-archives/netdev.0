From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] rdma/cm: Randomize local port allocation.
Date: Tue, 20 Apr 2010 12:34:25 +0800
Message-ID: <4BCD2ED1.4080702@redhat.com>
References: <5CE6BC7B954643FAAFFD2AD66F673CBD@amr.corp.intel.com>	<4BC7C9CF.20403@redhat.com>	<201004162254.FJF73478.SHOOMOFtQFVJLF@I-love.SAKURA.ne.jp> <20100416.133001.262206466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, sean.hefty@intel.com,
	opurdila@ixiacom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	rolandd@cisco.com, linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab0DTEbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 00:31:21 -0400
In-Reply-To: <20100416.133001.262206466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 16 Apr 2010 22:54:22 +0900
> 
>> Cong Wang wrote:
>>> Sean Hefty wrote:
>>>> I like this version, thanks!  I'm not sure which tree to merge it through.
>>>> Are you needing this for 2.6.34, or is 2.6.35 okay?
>>>>
>>> As soon as possible, so 2.6.34. :)
>>>
>> Cong, merge window for 2.6.34 was already closed.
>> You need to make your patchset towards 2.6.35 (using net-next-2.6 tree)
>> rather than 2.6.34 (using linux-2.6 tree). Therefore, this patch being
>> queued for 2.6.35 (through net-next-2.6 tree) should be okay for you.
> 
> I don't take RDMA patches into net-next-2.6, the less I touch this
> stack avoiding stuff the better and Roland has been taking this stuff
> into his own tree for some time now.

I left for a few days.

Ok, so I will wait for this to be merged.

Thanks, David and Tetsuo!

