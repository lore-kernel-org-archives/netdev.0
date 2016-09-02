From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc actions
Date: Fri, 2 Sep 2016 12:44:22 -0700
Message-ID: <CAM_iQpV4Ak3q406wVjY=X+ne7N2kCJdkWW8H8a07Wz2r-BhBdg@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com> <20160902070942.GB2150@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37545 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932340AbcIBTon (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 15:44:43 -0400
Received: by mail-it0-f54.google.com with SMTP id e124so57133950ith.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 12:44:43 -0700 (PDT)
In-Reply-To: <20160902070942.GB2150@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 12:09 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> I wonder, do you happen to have a very tiny narrow screen?

LOL, yeah, I should fix the indentation... ;)
