From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Thu, 11 Dec 2014 09:11:08 +0800
Message-ID: <5488EF2C.6010502@cn.fujitsu.com>
References: <5487DBD9.1010908@cn.fujitsu.com>  <1418194583.1047.8.camel@perches.com> <54880124.8040509@cn.fujitsu.com> <1418223106.18092.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418223106.18092.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,
On 12/10/2014 10:51 PM, Joe Perches wrote:

> On Wed, 2014-12-10 at 16:15 +0800, Gu Zheng wrote:
>> On 12/10/2014 02:56 PM, Joe Perches wrote:
>>> On Wed, 2014-12-10 at 13:36 +0800, Gu Zheng wrote:
>>>> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
>>>> cmsghdr from msghdr, just cleanup. 
>>>
>>> This looks nicer.
>>> Ideally this would have used: [PATCH V3] as the subject
>>
>> The previous v2 thread was marked as mistake, so this is the really active
>> v2 version.
> 
> A buggy submitted version is still a version.
> Using an incremented version number helps.

Got it, this can also avoid some unnecessary misreading.
Thanks for your suggestion.

Regards,
Gu

> 
> 
