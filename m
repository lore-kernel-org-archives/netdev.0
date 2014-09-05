From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] qdisc: exit case fixes for skb list handling
 in qdisc layer
Date: Fri, 05 Sep 2014 06:42:33 -0700
Message-ID: <1409924553.26422.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903.204256.1398300065789241714.davem@davemloft.net>
	 <1409808259.26422.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140904073912.6767fc20@redhat.com>
	 <20140904.224155.345294600116542200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33074 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756843AbaIENmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:42:37 -0400
Received: by mail-pa0-f53.google.com with SMTP id fa1so22264337pad.40
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:42:34 -0700 (PDT)
In-Reply-To: <20140904.224155.345294600116542200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 22:41 -0700, David Miller wrote:

> I put Eric's copy into my GIT tree on my workstation at home, build
> tested it, but did not push it out.
> 
> Then I did GIT work from my laptop for the following two days. :-/
> 
> Sorry about that.

No worries, I knew it was something like that ;)

Thanks !
