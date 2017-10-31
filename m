From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 05/11] ipsec: Create and use new helpers for dst
 child access.
Date: Tue, 31 Oct 2017 11:40:31 -0700
Message-ID: <1509475231.3828.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-6-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46939 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdJaSkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:40:33 -0400
Received: by mail-io0-f196.google.com with SMTP id 101so939026ioj.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:40:33 -0700 (PDT)
In-Reply-To: <20171031141054.9954-6-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> This will make a future change moving the dst->child pointer less
> invasive.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
