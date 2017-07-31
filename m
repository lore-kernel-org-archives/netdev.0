From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v12 0/4] net sched actions: improve dump
 performance
Date: Mon, 31 Jul 2017 16:43:45 -0700
Message-ID: <20170731164345.697d75c9@xeon-e3>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
        <20170730.192836.370680005861016480.davem@davemloft.net>
        <466dd890-ffae-4cdb-dc97-d173bd390148@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33447 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdGaXnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:43:47 -0400
Received: by mail-pg0-f51.google.com with SMTP id c14so496279pgn.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 16:43:47 -0700 (PDT)
In-Reply-To: <466dd890-ffae-4cdb-dc97-d173bd390148@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Jul 2017 08:06:42 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 17-07-30 10:28 PM, David Miller wrote:
> > 
> > Series applied, thanks.
> >   
> 
> Thanks David.
> 
> Attaching the iproute2 patch. I will submit an official one with
> man page  changes later. Stephen - you take net-next changes?
> 
> cheers,
> jamal

I will fix this up. The kernel headers for iproute2 come from sanitized
kernel headers (not direct copy).
