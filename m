From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix a UDP socket reference count bug in the
 pppol2tp driver
Date: Thu, 11 Feb 2010 13:00:51 -0800 (PST)
Message-ID: <20100211.130051.198184056.davem@davemloft.net>
References: <4B603C50.20406@katalix.com>
	<20100128.060717.99647383.davem@davemloft.net>
	<4B73EABC.5000707@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757062Ab0BKVAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 16:00:40 -0500
In-Reply-To: <4B73EABC.5000707@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 11 Feb 2010 11:32:12 +0000

> David Miller wrote:
>> From: James Chapman <jchapman@katalix.com>
>> Date: Wed, 27 Jan 2010 13:14:56 +0000
>> 
>>> Does the above help?
>> 
>> Thanks for the detailed explanation, I'll take another look
>> at this.
> 
> Did you get a chance to look at this?

Not yet, sorry.  Too many other things are preempting this
at the moment.
