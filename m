From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: enhance tcp_collapse_retrans() with
 skb_shift()
Date: Thu, 24 Nov 2016 13:42:11 -0800
Message-ID: <1480023731.8455.517.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479243110.8455.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479841053.8455.441.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161124.154208.1594403474025352610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34707 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966233AbcKXVmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:42:18 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so2212073pfb.1
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 13:42:13 -0800 (PST)
In-Reply-To: <20161124.154208.1594403474025352610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-24 at 15:42 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Nov 2016 10:57:33 -0800
> 
> > David, patch is marked 'Superseded' in
> > https://patchwork.ozlabs.org/patch/695264/
> > 
> > Not sure what this means exactly ?
> > Did I miss a mail/feedback/something ?
> 
> I must have mistakenly marked it that way, sorry.
> 
> Applied to net-next, thanks Eric.

Thanks David !
