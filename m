From: David Miller <davem@davemloft.net>
Subject: Re: net: prevent of emerging cross-namespace symlinks patches for
 3.14?
Date: Mon, 19 Jan 2015 21:19:30 -0500 (EST)
Message-ID: <20150119.211930.968922094604288712.davem@davemloft.net>
References: <54B6E36F.9060703@xs4all.net>
	<CAChDUfTktt7DAg+Mi0+PWcykhHWvE9wg5FNieWUuoBjZGsU8jQ@mail.gmail.com>
	<54BC3EF2.5080403@xs4all.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: git.user@gmail.com, netdev@vger.kernel.org, stable@vger.kernel.org
To: mikevs@xs4all.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54BC3EF2.5080403@xs4all.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miquel van Smoorenburg <mikevs@xs4all.net>
Date: Mon, 19 Jan 2015 00:17:06 +0100

> On 15/01/15 19:39, Alexander Y. Fomichev wrote:
>> On Thu, Jan 15, 2015 at 12:45 AM, Miquel van Smoorenburg
>> mikevs@xs4all.net> wrote:
>>> [first sent to lkml, now to netdev and the original patch author]
>>>
>>> When running 'lxc' on the latest -stable kernel, 3.14.28, I'm seeing
>>> these
>>> errors:
>>>
>>> Jan 14 17:47:16 lxc2 kernel: [ 10.704892] sysfs: cannot create
>>> duplicate
>>> filename '/devices/virtual/net/eth0.104/upper_eth0'
>>> I did not see these errors in 3.12. This was fixed in 3.17
>>
>> Hi,
>>
>> no objections of course,
>> actually it was written and tested with 3.14 in mind.
> 
> David, could you have a quick look and ack this if you agree this
> should go in 3.14-stable ?

Yes, this is fine, thanks for asking.
