From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: get rid of some forward declarations
Date: Tue, 8 Aug 2017 07:28:32 +0200
Message-ID: <20170808052832.GA1853@nanopsycho>
References: <20170807222650.16561-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36976 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751931AbdHHF2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 01:28:35 -0400
Received: by mail-wm0-f47.google.com with SMTP id t201so21601642wmt.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 22:28:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170807222650.16561-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 08, 2017 at 12:26:50AM CEST, xiyou.wangcong@gmail.com wrote:
>If we move up tcf_fill_node() we can get rid of these
>forward declarations.
>
>Also, move down tfilter_notify_chain() to group them together.
>
>Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
