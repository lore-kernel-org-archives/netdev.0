From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct
 on stack"
Date: Tue, 10 Jan 2017 10:48:05 -0800
Message-ID: <CAM_iQpUrvM_dj0rKYKjeTDx-pkYXqOydNPc5Dc8bxQVLN-z9iQ@mail.gmail.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170109.135259.988711786570465428.davem@davemloft.net> <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
 <20170110.131223.748150430551443881.davem@davemloft.net> <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35006 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755812AbdAJSs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:48:26 -0500
Received: by mail-qt0-f193.google.com with SMTP id f4so16236119qte.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:48:26 -0800 (PST)
In-Reply-To: <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 10:44 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Of course, there are just too many people too lazy to do a google search:
>
> https://lists.debian.org/debian-kernel/2013/05/msg00500.html
>

One more:
https://communities.intel.com/thread/28935 (<-- search icmp_send)
