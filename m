From: David Miller <davem@davemloft.net>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Wed, 20 Feb 2013 20:05:02 -0500 (EST)
Message-ID: <20130220.200502.1241369422255314068.davem@davemloft.net>
References: <5125002D.9080008@genband.com>
	<20130220152325.64c57d55@samsung-9>
	<51256E02.4080509@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: chris.friesen@genband.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab3BUBFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 20:05:07 -0500
In-Reply-To: <51256E02.4080509@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Friesen <chris.friesen@genband.com>
Date: Wed, 20 Feb 2013 18:44:50 -0600

> On 02/20/2013 05:23 PM, Stephen Hemminger wrote:
>> On Wed, 20 Feb 2013 10:56:13 -0600
>> Chris Friesen<chris.friesen@genband.com>  wrote:
>>
>>> Hi,
>>>
>>> I was just wondering why the kernel doesn't allow a new network
>>> protocol
>>> family to be loaded as as a kernel module built outside the kernel
>>> source tree.
> 
>> If you want an answer, to the question, use a tool like cscope and
>> learn to read the kernel code. There are several tables of pointers
>> sized by NPROTO.
> 
> That's a bit insulting, don't you think?

Absolutely not insulting at all.

The list is _NOT_ a place to go when you're just too damn lazy to take
the 10 seconds it would have taken to answer your question with a
quick NPROTO grep on the kernel sources.

Stephen's response to you was therefore %100 appropriate, and I would
have told you likewise if I had been the first to respond.
