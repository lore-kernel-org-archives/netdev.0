From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 1/1] forcedeth: add MII ioctls support
Date: Thu, 12 Dec 2013 11:08:30 -0800
Message-ID: <CAO7SqHBdy0aGWqNt7mJTbnA080sQmM1dX6hyZqJh4+8mqJiBPg@mail.gmail.com>
References: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
	<20131212.135644.122378813786715365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jiri Pirko <jiri@resnulli.us>, Patrick McHardy <kaber@trash.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:64504 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab3LLTIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 14:08:31 -0500
Received: by mail-ve0-f172.google.com with SMTP id jw12so646973veb.17
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 11:08:30 -0800 (PST)
In-Reply-To: <20131212.135644.122378813786715365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will look into that.Thanks!

On Thu, Dec 12, 2013 at 10:56 AM, David Miller <davem@davemloft.net> wrote:
> From: Salam Noureddine <noureddine@aristanetworks.com>
> Date: Wed, 11 Dec 2013 22:18:09 -0800
>
>> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
>
> I agree with Florian that using phylib would be a cleaner way to get
> this facility (and more).
