From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inaccurate packet scheduling
Date: Thu, 07 Feb 2013 08:39:35 -0800
Message-ID: <1360255175.28557.55.camel@edumazet-glaptop>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
	 <1355849503.9380.37.camel@edumazet-glaptop>
	 <20130102152601.GB1532@minipsycho.orion>
	 <1357144482.21409.16876.camel@edumazet-glaptop>
	 <20130108133038.GB1621@minipsycho.orion>
	 <20130124080536.GA1598@minipsycho.orion>
	 <1359036087.12374.2088.camel@edumazet-glaptop>
	 <20130129122357.GC7571@minipsycho.orion>
	 <1359475983.30177.2.camel@edumazet-glaptop>
	 <20130130121447.GB1604@minipsycho.orion>
	 <20130207161327.GA1619@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40850 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321Ab3BGQjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 11:39:40 -0500
Received: by mail-pa0-f43.google.com with SMTP id bh2so1486187pad.2
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 08:39:40 -0800 (PST)
In-Reply-To: <20130207161327.GA1619@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 17:13 +0100, Jiri Pirko wrote:

> >I tried kernel with this patch in. I also ported
> >56b765b79e9a78dc7d3f8850ba5e5567205a3ecd to tbf. I'm getting always the
> >similar numbers with iperf. There must be something else needed :/
> 
> Any other ideas?

You didn't post any patch, how can I comment on them ?
