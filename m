From: Shyam Saini <mayhs11saini@gmail.com>
Subject: Re: [PATCH] qed: Replace memset with eth_zero_addr
Date: Tue, 17 Jan 2017 09:03:05 +0530
Message-ID: <20170117033305.GB4055@mystictot>
References: <1484592698-19747-1-git-send-email-mayhs11saini@gmail.com>
 <20170116.145819.115892553691222296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32874 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdAQDdQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 22:33:16 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so4905205pfg.0
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 19:33:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170116.145819.115892553691222296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 02:58:19PM -0500, David Miller wrote:
> From: Shyam Saini <mayhs11saini@gmail.com>
> Date: Tue, 17 Jan 2017 00:21:38 +0530
> 
> > Use eth_zero_addr to assign zero address to the given address array
> > instead of memset when the second argument in memset is address
> > of zero. Also, it makes the code clearer
> > 
> > Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
> 
> This patch does not apply cleanly to the net-next tree.

I always send patches from linux-next tree and that caused this mistake

I apologize for this.

> Please state if you don't understand what that means instead of
> submitting this patch over and over again against the wrong source
> tree.

Now sent from net-next tree

Thanks a lot,
Shyam
