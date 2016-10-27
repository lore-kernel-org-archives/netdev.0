From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched actions: use nla_parse_nested()
Date: Thu, 27 Oct 2016 09:35:47 -0700
Message-ID: <CAM_iQpV+8Dg3hUsnkWDQXMKF+5gj9027hZJY8QH=pXbGzhyYtg@mail.gmail.com>
References: <1477485873-32598-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36572 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcJ0QgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 12:36:08 -0400
Received: by mail-yw0-f194.google.com with SMTP id o2so894120ywo.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 09:36:08 -0700 (PDT)
In-Reply-To: <1477485873-32598-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 5:44 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> Use nla_parse_nested instead of open-coding the call to
> nla_parse() with the attribute data/len.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
