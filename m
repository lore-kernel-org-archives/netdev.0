From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] tcp: Remove the unused parameter for
 tcp_try_fastopen.
Date: Tue, 22 Aug 2017 11:19:17 -0700
Message-ID: <1503425957.2499.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
         <1503383629-12392-3-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35521 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHVSTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:19:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id k3so1644175pfc.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 11:19:18 -0700 (PDT)
In-Reply-To: <1503383629-12392-3-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 23:33 -0700, Tonghao Zhang wrote:
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
>  include/net/tcp.h       | 3 +--
>  net/ipv4/tcp_fastopen.c | 6 ++----
>  net/ipv4/tcp_input.c    | 2 +-
>  3 files changed, 4 insertions(+), 7 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
