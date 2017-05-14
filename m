From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Sat, 13 May 2017 19:29:57 -0600
Message-ID: <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
 <20170504.104103.1628291573330660235.davem@davemloft.net>
 <20170504094356.66590a9a@xeon-e3> <20170504204318.GB21130@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>, daniel@iogearbox.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34479 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdENBaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 21:30:05 -0400
Received: by mail-it0-f65.google.com with SMTP id c26so9149704itd.1
        for <netdev@vger.kernel.org>; Sat, 13 May 2017 18:30:05 -0700 (PDT)
In-Reply-To: <20170504204318.GB21130@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 2:43 PM, Phil Sutter wrote:
> So in summary, given that very little change happens to iproute2's
> internal libnetlink, I don't see much urge to make it use libmnl as
> backend. In my opinion it just adds another potential source of errors.
> 
> Eventually this should be a maintainer level decision, though. :)

What is the decision on this?
