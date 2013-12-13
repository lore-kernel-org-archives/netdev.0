From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 2/6] net_sched: act: use standard struct list_head
Date: Fri, 13 Dec 2013 13:35:35 -0800
Message-ID: <CAM_iQpX+FRfOHmSKRePVbyBPAu1vixj4RO9NrWn9nQsti6=1-g@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-3-git-send-email-xiyou.wangcong@gmail.com>
	<52AAF8CB.6060006@mojatatu.com>
	<CAM_iQpVYkvpEH91y-c9ng4fpB+sayiTXnkkszw1=RosazeFuBA@mail.gmail.com>
	<52AB7C57.7010307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:62703 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3LMVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:35:36 -0500
Received: by mail-oa0-f51.google.com with SMTP id i7so2687938oag.38
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:35:36 -0800 (PST)
In-Reply-To: <52AB7C57.7010307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 1:29 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/13/13 13:48, Cong Wang wrote:
>
>> My English is not good, I can only find "head" or "list" here,
>> please suggest other better names?
>
>
> One of the ones you replaced was simply "actions"; that would be
> better.

OK, I will change "head" to "actions".
