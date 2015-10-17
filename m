From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: add pfmemalloc check in sk_add_backlog()
Date: Sat, 17 Oct 2015 09:04:01 -0700
Message-ID: <1445097841.30896.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150929.215607.1418732892830129304.davem@davemloft.net>
	 <1445009918.25595.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151017.050217.2095893802539811948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36656 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbbJQQEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 12:04:04 -0400
Received: by pacfv9 with SMTP id fv9so50903782pac.3
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 09:04:03 -0700 (PDT)
In-Reply-To: <20151017.050217.2095893802539811948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-10-17 at 05:02 -0700, David Miller wrote:

> Sorry I've been meaning to go back and apply it properly.  I'll do that right
> now...
> 
> There, done and properly queued up for -stable too. :)
> 

Perfect, thanks a lot David.
