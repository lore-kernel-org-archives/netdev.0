From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: refine TSO splits
Date: Fri, 13 Dec 2013 18:05:41 -0800
Message-ID: <1386986741.19078.191.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386971483.19078.188.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQy=Am3eOuZcGf3swzWRMa-GfutyCA_8V-K0of0booZwzhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42399 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab3LNCFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 21:05:53 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so3286202pbb.31
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 18:05:52 -0800 (PST)
In-Reply-To: <CADVnQy=Am3eOuZcGf3swzWRMa-GfutyCA_8V-K0of0booZwzhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 20:59 -0500, Neal Cardwell wrote:

> I love it! Thanks, Eric.
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>

Thanks a lot Neal !

Yes I think we found a winner here ;)
