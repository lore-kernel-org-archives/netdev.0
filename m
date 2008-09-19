From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [take 2] Re: [RFC PATCH] sched: only dequeue if packet can be
   queued to hardware queue.
Date: Fri, 19 Sep 2008 19:46:03 +0200
Message-ID: <48D3E55B.4030206@gmail.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain> <20080918194419.GA2982@ami.dom.local> <5f2db9d90809181811q74c3211fp9a099acb8e895fd4@mail.gmail.com> <20080919103225.GB9135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:60778 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbYISRof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 13:44:35 -0400
Received: by gv-out-0910.google.com with SMTP id e6so29648gvc.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 10:44:33 -0700 (PDT)
In-Reply-To: <20080919103225.GB9135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 09/19/2008 12:32 PM:

> Take 2:
> I missed __netif_schedule() in my patch, so the update below.


David,

After rethinking and reading Alexender's opinion I see this
change isn't needed so I withdraw this take 2.

Please, reconsider the first version of this patch (with your
2 patches), yet.

Thanks,
Jarek P.
