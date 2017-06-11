From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 2/4] net sched actions: Use proper root
 attribute table for actions
Date: Sun, 11 Jun 2017 15:55:10 +0200
Message-ID: <20170611135510.GB1896@nanopsycho.orion>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36199 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdFKNzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 09:55:13 -0400
Received: by mail-wr0-f195.google.com with SMTP id e23so16585796wre.3
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 06:55:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1497182026-11594-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jun 11, 2017 at 01:53:44PM CEST, jhs@mojatatu.com wrote:
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
