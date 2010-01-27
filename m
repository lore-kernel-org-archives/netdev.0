From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: [PATCH 1/2] syncookies: print synflood warning if syn queue is
	full
Date: Wed, 27 Jan 2010 18:01:24 +0100
Message-ID: <b2cc26e41001270901l5b5d7b26xc34965aabcd9c613@mail.gmail.com>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	 <1255722570-12803-1-git-send-email-fw@strlen.de>
	 <b2cc26e40912080647y5e441923n5186fd0cfff2bfdd@mail.gmail.com>
	 <20091208.130959.138311725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:34555 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571Ab0A0RB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 12:01:26 -0500
Received: by fxm7 with SMTP id 7so2845161fxm.28
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 09:01:24 -0800 (PST)
In-Reply-To: <20091208.130959.138311725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2009 at 10:09 PM, David Miller <davem@davemloft.net> wrote:
> From: Olaf van der Spek <olafvdspek@gmail.com>
> Date: Tue, 8 Dec 2009 15:47:59 +0100
>
>> On Fri, Oct 16, 2009 at 8:49 PM, Florian Westphal <fw@strlen.de> wrote:
>>> Always print a warning if the syn queue is full, just like
>>> the tcp/ipv6 code does.
>>>
>>> The "want_cookie" define is no longer needed -- gcc
>>> removes the relevant branches in the CONFIG_SYN_COOKIES=n case.
>>>
>>> Signed-off-by: Florian Westphal <fw@strlen.de>
>>
>> Any comments?
>
> You patch isn't even in patchwork any more, so for one thing
> it's definitely not in my queue any more.

Florian?
