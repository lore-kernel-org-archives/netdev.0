From: Yijing Wang <wangyijing@huawei.com>
Subject: Re: [PATCH 2/2] net/fddi: Replace local marco with PCI standard macro
Date: Fri, 6 Dec 2013 15:11:20 +0800
Message-ID: <52A17898.1090004@huawei.com>
References: <1386243482-32856-1-git-send-email-wangyijing@huawei.com>	<alpine.LFD.2.10.1312052154190.1599@eddie.linux-mips.org>	<52A13F34.2010403@huawei.com> <20131205.234420.2000965496889063263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <macro@linux-mips.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <guohanjun@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131205.234420.2000965496889063263.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/6 12:44, David Miller wrote:
> From: Yijing Wang <wangyijing@huawei.com>
> Date: Fri, 6 Dec 2013 11:06:28 +0800
> 
>> On 2013/12/6 6:06, Maciej W. Rozycki wrote:
>>> On Thu, 5 Dec 2013, Yijing Wang wrote:
>>>
>>>> Replace local marco DFX_BUS_PCI with PCI standard marco
>>>> dev_is_pci().
>>>
>>>  Typos above: marco -> macro
>>
>> Sorry for the mistake, David, should i need to resend this patch to fix this typo error?
> 
> You have to resubmit all of these conversions again because you posted
> them before the net-next tree was even open for submissions.
> 
> So you might as well fix the typos etc. while doing so.
> 
> 

OK, I have resent the two refreshed patches.


Thanks!
Yijing.


-- 
Thanks!
Yijing
