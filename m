From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v12 1/4] net netlink: Add new type NLA_BITFIELD32
Date: Sun, 30 Jul 2017 20:27:25 -0600
Message-ID: <c65cfbc7-8ead-bad4-7d75-f2dd7361bebf@gmail.com>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-2-git-send-email-jhs@emojatatu.com>
 <20170730184242.GA1872@nanopsycho>
 <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37111 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdGaC1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 22:27:23 -0400
Received: by mail-pg0-f66.google.com with SMTP id k190so13435460pgk.4
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 19:27:23 -0700 (PDT)
In-Reply-To: <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/17 1:59 PM, Jamal Hadi Salim wrote:
> On D. Ahern: I dont think we are disagreeing anymore on the need to
> generalize the check. He is saying it should be a helper and I already
> had the validation data; either works. I dont see the gapping need
> to remove the validation data.

I never disagreed on general code; I have always disagreed on validating
values as part of the policy check.
