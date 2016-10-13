From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Thu, 13 Oct 2016 23:08:42 +0200
Message-ID: <1476392922.5650.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161013.095403.1806984759673575482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36658 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753566AbcJMVJp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 17:09:45 -0400
Received: by mail-lf0-f66.google.com with SMTP id b75so14472431lfg.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 14:09:23 -0700 (PDT)
In-Reply-To: <20161013.095403.1806984759673575482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-13 at 09:54 -0400, David Miller wrote:
> Applied, thanks Eric.
> 
> Want me to queue this up for -stable too?

No thanks, it just occurred to me during a debugging session.
