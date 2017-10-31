From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 11/11] net: Remove dst->next
Date: Tue, 31 Oct 2017 11:52:39 -0700
Message-ID: <1509475959.3828.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-12-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:57288 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdJaSwl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:52:41 -0400
Received: by mail-io0-f194.google.com with SMTP id m81so948363ioi.13
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:52:41 -0700 (PDT)
In-Reply-To: <20171031141054.9954-12-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> There are no more users.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/dst.h | 4 ----
>  net/core/dst.c    | 1 -
>  2 files changed, 5 deletions(-)


Reviewed-by: Eric Dumazet <edumazet@google.com>
