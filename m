From: "John Ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrentlyrunsoftirqnetwork code on SMP
Date: Mon, 24 Sep 2007 11:48:21 +0800
Message-ID: <002401c7fe5d$c098c700$ca8510ac@asimco>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1> <1190551422.4256.36.camel@localhost> <000501c7fdf8$c7f7c8d0$d6ddfea9@JOHNYE1> <1190570864.4256.70.camel@localhost>
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<kaber@coreworks.de>, <iceburgue@gmail.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:24429 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbXIXDqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 23:46:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Jamal,

Thanks, bothered you all.

I will look into the 2 issues. re-ordering and spinlock, and do extensive
test.
Once having result, no matter positive or negative, I will contact you.
The format will not be a mess any more.

John Ye

----- Original Message -----
From: "jamal" <hadi@cyberus.ca>
To: "john ye" <johny@asimco.com.cn>
Cc: "David Miller" <davem@davemloft.net>; <netdev@vger.kernel.org>;
<kuznet@ms2.inr.ac.ru>; <pekkas@netcore.fi>; <jmorris@namei.org>;
<kaber@coreworks.de>; <iceburgue@gmail.com>
Sent: Monday, September 24, 2007 2:07 AM
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network:
concurrentlyrunsoftirqnetwork code on SMP


> John,
> It will NEVER be an acceptable solution as long as you have re-ordering.
> I will look at it - but i have to run out for now. In the meantime,
> I have indented it for you to be in proper kernel format so others can
> also look it. Attached.
>
> cheers,
> jamal
>
>


