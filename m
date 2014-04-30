From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] RCU'ify the net:sched classifier chains
Date: Wed, 30 Apr 2014 09:36:01 -0700
Message-ID: <53612671.4020802@gmail.com>
References: <20140110092041.7193.5952.stgit@nitbit.x32> <CAM_iQpU6WWB72zBdU4mh-sB+8B8Vz2gPvH7Hxhjhkr+vMjwdpw@mail.gmail.com> <52D1D4BD.9080906@gmail.com> <CAM_iQpXaoPjbtCGbWBWbUbSSW2H57mmGD3sqzw5pgWyEuHdtKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:57165 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759446AbaD3QgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:36:16 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so2300832obc.9
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 09:36:15 -0700 (PDT)
In-Reply-To: <CAM_iQpXaoPjbtCGbWBWbUbSSW2H57mmGD3sqzw5pgWyEuHdtKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 04:51 PM, Cong Wang wrote:
> Hi, John
>
> Do you have any plan to update this patchset and resend them?
>
> Thanks.
>

OK, I updated the patch set and sent it out. Still need to get
the latest perf numbers for an official submission. any testing
and/or review you can do would be great. Hoping to wrap this up
and get it out soon.

Thanks,
John

-- 
John Fastabend         Intel Corporation
