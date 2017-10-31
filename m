From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 03/11] ipv6: Move rt6_next from dst_entry into
 ipv6 route structure.
Date: Tue, 31 Oct 2017 11:37:15 -0700
Message-ID: <1509475035.3828.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-4-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:44476 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdJaShR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:37:17 -0400
Received: by mail-io0-f179.google.com with SMTP id m16so935917iod.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:37:17 -0700 (PDT)
In-Reply-To: <20171031141054.9954-4-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
Reviewed-by: Eric Dumazet <edumazet@google.com>
