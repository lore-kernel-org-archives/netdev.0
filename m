From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ep93xx_eth.c: general cleanup
Date: Wed, 23 Dec 2009 14:14:58 -0800 (PST)
Message-ID: <20091223.141458.193725880.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090200ED0C@mi8nycmail19.Mi8.com>
	<20091216183200.GN1819@mail.wantstofly.org>
	<BD79186B4FD85F4B8E60E381CAEE19090200ED18@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757391AbZLWWPA@vger.kernel.org>
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200ED18@mi8nycmail19.Mi8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Wed, 16 Dec 2009 13:34:55 -0500

> Wednesday, December 16, 2009 11:32 AM, Lennert Buytenhek wrote:
>> On Wed, Dec 16, 2009 at 01:18:13PM -0500, H Hartley Sweeten wrote:
>>
>>> V3 - Change pr_fmt() as suggested by Joe Perches
>>>      Don't remove DRV_MODULE_NAME and DRV_MODULE_VERSION
>>>      Don't remove the message in ep93xx_eth_init_module()
>>
>> That's not what I meant, but alright, as you prefer.
> 
> Guess my parser is off line today.... ;-)
> 
> What did you mean?

This patch also doesn't apply to current sources, so if you
could also please respin this once you've resolved the feedback
that would be great.

Thanks.
