From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] ss: print tcpi_rcv_mss and tcpi_advmss
Date: Mon, 6 Feb 2017 13:51:43 -0800
Message-ID: <20170206135143.6f46f5fc@xeon-e3>
References: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
        <1486043247.13103.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33005 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751115AbdBFVvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:51:45 -0500
Received: by mail-pf0-f170.google.com with SMTP id y143so26933337pfb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:51:45 -0800 (PST)
In-Reply-To: <1486043247.13103.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Feb 2017 05:47:27 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> tcpi_rcv_mss and tcpi_advmss tcp info fields were not yet reported
> by ss.
> 
> While adding GRO support to packetdrill, I found this was useful.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
