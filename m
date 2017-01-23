From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/tcp-fastopen: refactor cookie check
 logic
Date: Mon, 23 Jan 2017 11:13:36 -0800
Message-ID: <1485198816.16328.209.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
         <20170123185922.48046-2-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36528 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWTNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:13:38 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so14408849pgf.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:13:37 -0800 (PST)
In-Reply-To: <20170123185922.48046-2-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 10:59 -0800, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> Refactor the cookie check logic in tcp_send_syn_data() into a function.
> This function will be called else where in later changes.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
