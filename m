From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] typhoon: fix PCI enable, add port IO option
Date: Fri, 07 Jan 2005 02:23:54 -0500
Message-ID: <41DE390A.2050002@pobox.com>
References: <1101535273.4734.3.camel@ori.thedillows.org>	 <41DE0648.6090302@pobox.com> <1105079709.6202.4.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1105079709.6202.4.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Dillow wrote:
> On Thu, 2005-01-06 at 22:47 -0500, Jeff Garzik wrote:
> 
>>David Dillow wrote:
>>
>>>Jeff, please do a
>>>
>>>	bk pull http://typhoon.bkbits.net/typhoon-2.6
>>
>>Unfortunately, I can't pull this since it is not based on vanilla 
>>upstream 2.6.x.
> 
> 
> Heh, I based it off netdev-2.6 at the time, because, IIRC, there were
> changes in it that hadn't been pushed to Linus yet, and hadn't come
> through me to be picked up in my tree. (There may be a way for me to do
> it, I didn't try very hard.)

it's a natural guess to base it off of netdev-2.6, but that's mainly for 
people who send patches.  For BitKeeper, it's better to base it off a 
vanilla linux-2.6 tree.


>>Can you please re-create your typhoon repository, based only on Linus's 
>>2.6.x?
> 
> 
> Sure thing, it is there now. Content hasn't changed from the broken-out
> patches I sent earlier, but I broke the file deltas into changesets of
> their own.

thanks, pulled.

	Jeff
