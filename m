From: "long.wanglong" <long.wanglong@huawei.com>
Subject: Re: [PATCH] netevent: remove automatic variable in register_netevent_notifier()
Date: Fri, 29 May 2015 08:56:03 +0800
Message-ID: <5567B923.9000608@huawei.com>
References: <1432807250-223365-1-git-send-email-long.wanglong@huawei.com> <55672139.1050306@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <peifeiyue@huawei.com>,
	<wanglong@laoqinren.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55672139.1050306@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/5/28 22:07, Sergei Shtylyov wrote:
> Hello.
> 
> On 5/28/2015 1:00 PM, Wang Long wrote:
> 
>> Remove automatic variable 'err' in register_netevent_notifier() and
>> return the return value of atomic_notifier_chain_register() directly.
> 
>    s/return value/result/, in order to avoid tautology.
> 
>> Signed-off-by: Wang Long <long.wanglong@huawei.com>
> [...]
> 
> WBR, Sergei
> 
> 
> 

Thanks, I will fix that.

Best Regards
Wang Long
