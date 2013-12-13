From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 16:29:12 -0500
Message-ID: <52AB7C28.5080102@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>	<52AAF7FD.3090207@mojatatu.com> <CAM_iQpXVc7NW2dqkKL211Js_AGERwN2tY=KB-AJsfxcxMqgO0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:50413 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3LMV3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:29:14 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so1995882igc.3
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:29:13 -0800 (PST)
In-Reply-To: <CAM_iQpXVc7NW2dqkKL211Js_AGERwN2tY=KB-AJsfxcxMqgO0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 13:38, Cong Wang wrote:

> Yes, but I just have testcase for u32 filter and basic filter with
> mirred action. I don't have time to write testcases for other things
> yet.

Good - at least you are testing. Please fix your patches based on
comments you received and i will do more testing on my side when
your patches are in good shape.

cheers,
jamal
