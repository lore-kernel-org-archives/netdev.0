From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 repost 2/3] tc: actions: add helpers to parse
 and print control actions
Date: Wed, 14 Jun 2017 22:10:07 +0200
Message-ID: <20170614201007.GB1972@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172937.1391-2-jiri@resnulli.us>
 <20170614203222.3dcc183d@griffin>
 <20170614191850.GA1972@nanopsycho>
 <20170614212824.757ca744@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:36255 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdFNUKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:10:10 -0400
Received: by mail-wr0-f173.google.com with SMTP id 36so15471092wry.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 13:10:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170614212824.757ca744@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 14, 2017 at 09:28:24PM CEST, jbenc@redhat.com wrote:
>On Wed, 14 Jun 2017 21:18:50 +0200, Jiri Pirko wrote:
>> Isn't it fixed by:
>> 
>> https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/commit/?h=net-next&id=18f05d06016d9492c87fd105d831de0d6d858f43
>> 
>> ?
>
>Doesn't seem so. The current net-next branch with this commit included
>fails in the same way.

Will fix tmrw. Thanks!


>
> Jiri
