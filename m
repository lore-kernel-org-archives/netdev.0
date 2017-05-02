From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: Re: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Tue, 2 May 2017 11:47:47 +0200
Message-ID: <5220cb6f-b7ee-a5a3-6858-7d51097d0ee2@6wind.com>
References: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
 <20170501092915.5c19395c@xeon-e3> <5907717B.3060608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34852 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751217AbdEBJry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 05:47:54 -0400
Received: by mail-wm0-f53.google.com with SMTP id w64so106445911wma.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 02:47:53 -0700 (PDT)
In-Reply-To: <5907717B.3060608@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel, Stephen,

2017-05-01 (19:33 +0200) ~ Daniel Borkmann <daniel@iogearbox.net>
> [ +Quentin ]
> 
> On 05/01/2017 06:29 PM, Stephen Hemminger wrote:
>> On Fri, 28 Apr 2017 15:44:29 +0200
>> Daniel Borkmann <daniel@iogearbox.net> wrote:
>>

[…]

>> Does bash-completion need update?
> 
> Yeah, so far there's only a bash completion for the tc tool
> in the tree, but nothing else. Is there anything in the works
> for covering other tools, Quentin?
> 
> Thanks again,
> Daniel

I am not working on bash completion for other tools at the moment, but
it appears that several of them are already covered. Not in iproute2,
but in bash-completions repository [1]. There is at least some support
for ip (last updated 4 months ago, it seems) [2], for ss and for tipc.
It would be nice to have everything in the iproute2 tree, though.

Best,
Quentin

[1] https://github.com/scop/bash-completion
[1] https://github.com/scop/bash-completion/blob/master/completions/ip
