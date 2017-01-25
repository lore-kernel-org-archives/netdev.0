From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 18:54:58 +0100
Message-ID: <20170125175458.GF23545@1wt.eu>
References: <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170124191127.GG21921@1wt.eu>
 <CAC15z3izWNh7th_yxA_a90vgLnU5XzVDm6vyojq3cMDgQZ71YA@mail.gmail.com>
 <20170125.122205.9460825196595773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tracywwnj@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
        weiwan@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:2398 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750965AbdAYRzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 12:55:05 -0500
Content-Disposition: inline
In-Reply-To: <20170125.122205.9460825196595773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 12:22:05PM -0500, David Miller wrote:
> From: Wei Wang <tracywwnj@gmail.com>
> Date: Wed, 25 Jan 2017 09:15:34 -0800
> 
> > Looks like you sent a separate patch on top of this patch series to
> > address double connect().  Then I think this patch series should be
> > good to go.
> 
> Indeed, Willy please give some kind of ACK.

Yes sorry David, for me it's OK. If Wei runs his whole series of tests
on it again, it should be perfect.

thanks,
Willy
