From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: act: remove capab from struct tc_action_ops
Date: Thu, 16 Jan 2014 10:28:56 -0800
Message-ID: <CAM_iQpU=BMczigmLRBNRUE70vCw=gpCHya_jF84wGqQu7r12Eg@mail.gmail.com>
References: <1389829770-811-1-git-send-email-xiyou.wangcong@gmail.com>
	<52D7DEDF.6050006@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:48988 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaAPS26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 13:28:58 -0500
Received: by mail-oa0-f50.google.com with SMTP id n16so336173oag.37
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 10:28:58 -0800 (PST)
In-Reply-To: <52D7DEDF.6050006@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 5:30 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 01/15/14 18:49, Cong Wang wrote:
>>
>> It is not actually implemented.
>
>
> Why dont you do something more useful like allow user to
> query capability?
> If that doesnt make sense - lets talk offline.
>

It does. But who cares? The code was there since the beginning
of git history, no one complains it is not implemented. :)

If you or someone else requests for it, we can definitely keep it.
