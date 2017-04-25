From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v8 1/3] net sched actions: Use proper root
 attribute table for actions
Date: Tue, 25 Apr 2017 20:42:20 +0200
Message-ID: <20170425184219.GA19307@vergenet.net>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38197 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030622AbdDYSmY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 14:42:24 -0400
Received: by mail-wm0-f48.google.com with SMTP id r190so104878873wme.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:42:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493121247-11863-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 07:54:05AM -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Bug fix for an issue which has been around for about a decade.
> We got away with it because the enumeration was larger than needed.
> 
> Fixes: 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")
> Suggested-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
