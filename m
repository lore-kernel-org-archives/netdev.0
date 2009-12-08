From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] syncookies: print synflood warning if syn queue is
 full
Date: Tue, 08 Dec 2009 13:09:59 -0800 (PST)
Message-ID: <20091208.130959.138311725.davem@davemloft.net>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	<1255722570-12803-1-git-send-email-fw@strlen.de>
	<b2cc26e40912080647y5e441923n5186fd0cfff2bfdd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olafvdspek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52222
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753285AbZLHVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 16:09:53 -0500
In-Reply-To: <b2cc26e40912080647y5e441923n5186fd0cfff2bfdd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olaf van der Spek <olafvdspek@gmail.com>
Date: Tue, 8 Dec 2009 15:47:59 +0100

> On Fri, Oct 16, 2009 at 8:49 PM, Florian Westphal <fw@strlen.de> wrote:
>> Always print a warning if the syn queue is full, just like
>> the tcp/ipv6 code does.
>>
>> The "want_cookie" define is no longer needed -- gcc
>> removes the relevant branches in the CONFIG_SYN_COOKIES=n case.
>>
>> Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Any comments?

You patch isn't even in patchwork any more, so for one thing
it's definitely not in my queue any more.
