From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2 v2 repost 3/3] tc/actions: introduce support
 for goto chain action
Date: Fri, 2 Jun 2017 10:22:42 +0200
Message-ID: <20170602102242.79874389@griffin>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-3-jiri@resnulli.us>
        <20170531142702.6d0ca6fa@griffin>
        <20170602081512.GB2015@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751149AbdFBIWx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 04:22:53 -0400
In-Reply-To: <20170602081512.GB2015@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Jun 2017 10:15:12 +0200, Jiri Pirko wrote:
> 0 only. I exepcter it makes sense. But you are right, I will put it to
> man.

Thanks!

> Basically, what we had previously was single chain (0) only. Now we have
> multichain, each chain is completely independent list of tps, each tp
> having its prio.

Okay, chains are superior to priorities. It was not clear :-)

> I will also add this to man.

Thanks,

 Jiri
