From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: print tcpi_rcv_mss
Date: Thu, 02 Feb 2017 05:44:20 -0800
Message-ID: <1486043060.13103.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33439 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBNoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 08:44:22 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so1540585pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 05:44:22 -0800 (PST)
In-Reply-To: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 16:36 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> tcpi_rcv_mss tcp info field was not yet reported by ss.
> 
> While adding GRO support to packetdrill, I found this was useful.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Will send a V2, also adding advmss.
