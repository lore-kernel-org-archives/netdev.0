From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 09:29:38 -0800
Message-ID: <1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	 <52B434FA.8080309@mojatatu.com>
	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B45851.90208@mojatatu.com>
	 <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:60953 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab3LTR3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:29:41 -0500
Received: by mail-yh0-f46.google.com with SMTP id l109so670447yhq.33
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:29:41 -0800 (PST)
In-Reply-To: <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 09:20 -0800, Eric Dumazet wrote:

> 
> The winner is :
> 

> # first bad commit: [3627287463b4acddb83d24fabb1e0a304e39565c]
> net_sched: convert tcf_proto_ops to use struct list_head
> 

I am testing a fix.
