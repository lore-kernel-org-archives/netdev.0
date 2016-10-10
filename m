From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2-next] tc: fq: display unthrottle latency
Date: Sun, 9 Oct 2016 19:15:45 -0700
Message-ID: <20161009191545.7e670800@xeon-e3>
References: <1475068995.28155.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35887 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750809AbcJJCQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 22:16:04 -0400
Received: by mail-pa0-f45.google.com with SMTP id ry6so45810100pac.3
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 19:15:30 -0700 (PDT)
In-Reply-To: <1475068995.28155.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 06:23:15 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> In linux-4.9 fq packet scheduler got a new stat :
> 
> unthrottle_latency in nano second units.
> 
> Gives a good indication of system load or timer implementation
> latencies.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next (for 4.9)
