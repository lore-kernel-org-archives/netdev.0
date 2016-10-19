From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: potential deadlock in do_ipv6_setsockopt
Date: Wed, 19 Oct 2016 09:36:04 -0700
Message-ID: <CAM_iQpWFVXEcCNfaDeiL0e9Q4J=bOo5EfD995hikPxmgQrUU_w@mail.gmail.com>
References: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
 <CAM_iQpWKfkkYzF6yb9fGQsieGwok196kqGtRNVVS_ULxZghyew@mail.gmail.com>
 <ec7e340c-132f-549d-9c30-b6e903cc7666@gmail.com> <6e9dbe30-ec0f-07cb-0e16-d86eb4bc480f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35901 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbcJSQg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 12:36:26 -0400
Received: by mail-it0-f52.google.com with SMTP id 139so109816446itm.1
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 09:36:25 -0700 (PDT)
In-Reply-To: <6e9dbe30-ec0f-07cb-0e16-d86eb4bc480f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 12:45 AM, Baozeng Ding <sploving1@gmail.com> wrote:
> It fixes the issue for me.
> Tested-by: Baozeng Ding <sploving1@gmail.com>

Thanks for testing, I will send out the patch formally very soon.

BTW, you can check mailing archive to see if your email succeeds or not,
for example, http://marc.info/?l=linux-netdev
