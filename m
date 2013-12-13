From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 13:34:14 -0800
Message-ID: <CAM_iQpWq64+Ae-ZESxGxGMLeFE2tRJeBGF+6E0-w5Qer2zk+3g@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>
	<CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>
	<52AB7BC6.9050503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:45012 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3LMVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:34:14 -0500
Received: by mail-oa0-f50.google.com with SMTP id n16so2702318oag.23
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:34:14 -0800 (PST)
In-Reply-To: <52AB7BC6.9050503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 1:27 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/13/13 13:33, Cong Wang wrote:
>
>> Why? Keep in mind that we don't need to worry about any
>> out-of-tree modules. :)
>
>
> This is an API that is used to export additional stats that
> are not generic.
>

But no in-tree module implements it....
