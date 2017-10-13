From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/34] net: sched: allow qdiscs to share filter
 block instances
Date: Fri, 13 Oct 2017 08:21:01 +0200
Message-ID: <20171013062101.GA1952@nanopsycho.orion>
References: <20171012171823.1431-1-jiri@resnulli.us>
 <20171012.102148.580269505585324793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:50397 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdJMGVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 02:21:03 -0400
Received: by mail-wm0-f44.google.com with SMTP id u138so18455155wmu.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 23:21:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012.102148.580269505585324793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 12, 2017 at 07:21:48PM CEST, davem@davemloft.net wrote:
>
>Jiri I'm not looking at a 34 patch set, it's too large.
>
>Break this up into groups of a dozen or so patches each, no
>more.  Submit them one at a time and wait for each series
>to be fully reviewed and integrated before moving onto the
>next one.

Yeah. As I stated in the beginning of the cover letter, I did not find a
way to do it. I could split into 2 of 3 patchsets, problem is that I
would introduce interfaces in first patchset that would be only used in
patchset 2 or 3. I believe that is not ok. Do you think that I can do it
like this this time?

Thanks
