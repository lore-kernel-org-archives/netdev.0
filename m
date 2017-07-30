From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v12 2/4] net sched actions: Use proper root
 attribute table for actions
Date: Sun, 30 Jul 2017 20:44:58 +0200
Message-ID: <20170730184458.GB1872@nanopsycho>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38596 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754193AbdG3SpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 14:45:01 -0400
Received: by mail-wr0-f196.google.com with SMTP id g32so12795167wrd.5
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 11:45:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1501435492-28301-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 30, 2017 at 07:24:50PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Bug fix for an issue which has been around for about a decade.
>We got away with it because the enumeration was larger than needed.
>
>Fixes: 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")
>Suggested-by: Jiri Pirko <jiri@mellanox.com>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
