From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv6/dccp: do not inherit ipv6_mc_list from parent
Date: Tue, 09 May 2017 17:21:56 -0700
Message-ID: <1494375716.7796.101.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494374394-24373-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36351 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdEJAV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 20:21:59 -0400
Received: by mail-pf0-f172.google.com with SMTP id m17so7535692pfg.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 17:21:59 -0700 (PDT)
In-Reply-To: <1494374394-24373-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 16:59 -0700, Cong Wang wrote:
> Like commit 657831ffc38e ("dccp/tcp: do not inherit mc_list from parent")
> we should clear ipv6_mc_list etc. for IPv6 sockets too.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
