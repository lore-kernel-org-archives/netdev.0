From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net v3 0/3] net_sched: fix filter chain reference counting
Date: Wed, 13 Sep 2017 08:13:30 +0200
Message-ID: <20170913061330.GB1922@nanopsycho>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170912.204118.1990439437521288402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        jiri@mellanox.com, jakub.kicinski@netronome.com, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37979 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdIMGNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 02:13:32 -0400
Received: by mail-wr0-f194.google.com with SMTP id p37so7207344wrb.5
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 23:13:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170912.204118.1990439437521288402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 13, 2017 at 05:41:18AM CEST, davem@davemloft.net wrote:
>From: Cong Wang <xiyou.wangcong@gmail.com>
>Date: Mon, 11 Sep 2017 16:33:29 -0700
>
>> This patchset fixes tc filter chain reference counting and nasty race
>> conditions with RCU callbacks. Please see each patch for details.
>
>Series applied, thanks Cong.

Ha, so after :)
