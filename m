From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/34] net: sched: allow qdiscs to share
 filter block instances
Date: Thu, 12 Oct 2017 10:21:48 -0700 (PDT)
Message-ID: <20171012.102148.580269505585324793.davem@davemloft.net>
References: <20171012171823.1431-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755408AbdJLRVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:21:50 -0400
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jiri I'm not looking at a 34 patch set, it's too large.

Break this up into groups of a dozen or so patches each, no
more.  Submit them one at a time and wait for each series
to be fully reviewed and integrated before moving onto the
next one.

Thanks.
