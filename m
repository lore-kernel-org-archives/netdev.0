From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: kill u32_node pointer in Qdisc
Date: Wed, 23 Aug 2017 19:02:50 -0700
Message-ID: <CAM_iQpUZshuu-RxO-kxBpcVj7fA_H5jJuC=LxhLoHdmGT-avdQ@mail.gmail.com>
References: <20170823175854.21924-1-xiyou.wangcong@gmail.com>
 <20170823202553.GC2015@nanopsycho> <CAM_iQpXx4BnkOQPBu7G12BAnGB_W18=dSJRjg206K6ek+8=o8g@mail.gmail.com>
 <20170823212056.GA22713@nanopsycho> <CAM_iQpXHg4jd4vtq0O3uAV6ONYA18M0MqJRs=P=FAmyCyf1eFA@mail.gmail.com>
 <20170823213839.GB22713@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:37248 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751094AbdHXCDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 22:03:11 -0400
Received: by mail-pg0-f43.google.com with SMTP id y129so8696786pgy.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 19:03:11 -0700 (PDT)
In-Reply-To: <20170823213839.GB22713@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 2:38 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> I would not have to spend any time on it, if you would just follow the
> usual workflow. Clearly, you have some problem with that. I cannot
> say I understand it :/

You are amazing, you still waste your time even after I said
"I can fix it"...

You need look at current code base to see how much is
over 80-cols, not everyone agrees with you or checkpatch.pl.

Feel free to waste your time, but don't waste others', please.
