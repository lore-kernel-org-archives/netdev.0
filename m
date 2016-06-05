From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Sun, 05 Jun 2016 13:55:23 -0700
Message-ID: <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160604190301.GA8857@strlen.de>
	 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
	 <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33233 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbcFEUzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 16:55:25 -0400
Received: by mail-pa0-f47.google.com with SMTP id ec8so23146945pac.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 13:55:25 -0700 (PDT)
In-Reply-To: <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-05 at 13:54 -0700, Eric Dumazet wrote:

> BTW, we might need a similar fix in sch_fq.c

I meant sch_sfq.c
