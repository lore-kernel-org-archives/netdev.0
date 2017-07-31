From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v12 1/4] net netlink: Add new type NLA_BITFIELD32
Date: Mon, 31 Jul 2017 08:38:33 +0200
Message-ID: <20170731063833.GB1883@nanopsycho>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-2-git-send-email-jhs@emojatatu.com>
 <20170730184242.GA1872@nanopsycho>
 <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38438 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdGaGig (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 02:38:36 -0400
Received: by mail-wm0-f45.google.com with SMTP id m85so160750786wma.1
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 23:38:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 30, 2017 at 09:59:10PM CEST, jhs@mojatatu.com wrote:
>Jiri,
>
>This is getting exhausting, seriously.
>I posted the code you are commenting one two days ago so i dont have to
>repost.

And I commented on the "*u32 = *u32" thing. But you ignored it. Pardon
me for mentioning that again now :/


>
>On D. Ahern: I dont think we are disagreeing anymore on the need to
>generalize the check. He is saying it should be a helper and I already
>had the validation data; either works. I dont see the gapping need
>to remove the validation data.

DavidA? Your opinion.
