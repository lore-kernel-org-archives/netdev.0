From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: diag: fix a potential security issue
Date: Sat, 21 Oct 2017 12:16:59 +0100 (WEST)
Message-ID: <20171021.121659.925589637636130294.davem@davemloft.net>
References: <1508571955.30291.21.camel@edumazet-glaptop3.roam.corp.google.com>
        <CADvbK_cKxwVxVbJU1uTVN1Goz_Wju1q71a0qUDWXY-zLCYNhhw@mail.gmail.com>
        <CADvbK_cLxOGpBwdSX+CkE+HLefT4rjz8tbgrkosGg7f+wmQVTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, marcelo.leitner@gmail.com,
        sd@queasysnail.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932067AbdJULRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 07:17:06 -0400
In-Reply-To: <CADvbK_cLxOGpBwdSX+CkE+HLefT4rjz8tbgrkosGg7f+wmQVTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 21 Oct 2017 17:45:09 +0800

> Let's just see if David could accept the patches if I will
> remove the "security claim" from changelog, considering
> it as an improvement of sock diag.
> 
> David ?

No I won't.  See my other response.

Use modules.conf or netfilter rules to block "scary networking
protocols" if you are so paranoid about this happening.

Thank you.
