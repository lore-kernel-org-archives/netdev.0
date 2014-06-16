From: chenweilong <chenweilong@huawei.com>
Subject: Re: [request for stable inclusion] ipv6: reallocate addrconf router
 for ipv6 address when lo device up
Date: Mon, 16 Jun 2014 11:14:39 +0800
Message-ID: <539E611F.6000805@huawei.com>
References: <1402884279-11896-1-git-send-email-chenweilong@huawei.com> <20140615.192955.2126802764510967888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <gaofeng@cn.fujitsu.com>,
	<stable@vger.kernel.org>, <netdev@vger.kernel.org>,
	<hannes@stressinduktion.org>, <sd@queasysnail.net>,
	<lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140615.192955.2126802764510967888.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oh..sorry,

I must missed something important!
What's the right way?

This patch solves the bug is 67951 on bugzilla
https://bugzilla.kernel.org/show_bug.cgi?id=67951
It's very worthy to be applied to stable 3.4.x kernels.
As this patch can't be applied directly, I just modify
it in my last mail,

Thanks,

Weilong

On 2014/6/16 10:29, David Miller wrote:
> From: Chen Weilong <chenweilong@huawei.com>
> Date: Mon, 16 Jun 2014 10:04:39 +0800
> 
>> From: Gao feng <gaofeng@cn.fujitsu.com>
>>
>> commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 upstream.
>>
>> /* CHANGELOG */
>>
> 
> No, this is not how you ask for networking changes to be submitted to
> -stable.
> 
> 
