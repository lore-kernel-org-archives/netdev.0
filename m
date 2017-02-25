From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: fix overflow in mlx4_en_init_timestamp()
Date: Sat, 25 Feb 2017 18:11:07 +0200
Message-ID: <CAJ3xEMhLLd490Yknp01t7STh2jjAyAJ4XFmkzCxH7bXd-kHuUA@mail.gmail.com>
References: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com> <20170224.112104.1212046772081988137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f177.google.com ([74.125.82.177]:34578 "EHLO
        mail-ot0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdBYQSy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2017 11:18:54 -0500
Received: by mail-ot0-f177.google.com with SMTP id x10so31059410otb.1
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2017 08:18:54 -0800 (PST)
In-Reply-To: <20170224.112104.1212046772081988137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 6:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 23 Feb 2017

> Tariq please review.

Dave,

Just to re-iterate what we wrote here couple of time, the IL WW is
Sun-Thu on GMT+2 hours and hence this patch was sent when the
developers/maintainer are into weekend mode.

Or.
