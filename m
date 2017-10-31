From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 01/11] net: dst->rt_next is unused.
Date: Tue, 31 Oct 2017 11:36:04 -0700
Message-ID: <1509474964.3828.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-2-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44487 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdJaSgH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:36:07 -0400
Received: by mail-io0-f194.google.com with SMTP id m16so927695iod.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:36:07 -0700 (PDT)
In-Reply-To: <20171031141054.9954-2-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> Delete it.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
