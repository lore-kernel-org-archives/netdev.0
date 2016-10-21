From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 08:45:18 -0700
Message-ID: <1477064718.7065.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
         <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
         <1477055663.7065.67.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161021.110333.1897572143781385600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jikos@kernel.org, jhs@mojatatu.com, phil@nwl.cc,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33043 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933352AbcJUPpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 11:45:20 -0400
In-Reply-To: <20161021.110333.1897572143781385600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-21 at 11:03 -0400, David Miller wrote:

> If this is changing default behavior we should approach this the other
> way around.
> 
> Keep behaving the way we do, user asks for new behavior with the attribute.
SGTM
