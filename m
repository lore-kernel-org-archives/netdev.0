From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 4/6] netprio_cgroup: use IS_ENABLED() and family
Date: Wed, 01 Feb 2012 15:22:59 +0800
Message-ID: <4F28E853.7000104@cn.fujitsu.com>
References: <4F28E203.10502@cn.fujitsu.com>	<20120201.015954.2098592611164231843.davem@davemloft.net>	<4F28E48D.3040505@cn.fujitsu.com> <20120201.020738.1965865410881089752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120201.020738.1965865410881089752.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> Do not mix genuine bug fixes and cleanups.
>>>
>>> Otherwise I cannot apply your bug fixes to the 'net' tree.
>>>
>>> Seperate things out, submit only pure bug fixes first, then
>>> later once those changes propagate you can submit the cleanups.
>>>
>>
>> I did seperate them out, so the first three patches are fixes,
>> and others are cleanups. I can resend cleanup patches once
>> fixes hit mainline.
> 
> Seperate them in different groups, don't submit them as one
> collection.  And definitely don't submit them all at the
> same damn time!  You have to wait with the dependent cleanups
> until the fixes go in, and subsequently show up in my net-next
> tree.
> 
> I'm not applying this stuff until you submit it properly, in
> two stages.
> 

I'll do this when I get some comments/acks.
