From: Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH v2 net-next 0/6] perf, bpf: add support for bpf in sw/hw perf_events
Date: Wed, 31 Aug 2016 17:18:35 -0700
Message-ID: <CAE40pdeaE=NParweu7A-sa_2VM9EDju8KLOt=BWF1POnRw9qtQ@mail.gmail.com>
References: <1472680243-1326608-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34641 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753364AbcIAATH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 20:19:07 -0400
In-Reply-To: <1472680243-1326608-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 2:50 PM, Alexei Starovoitov <ast@fb.com> wrote:
> Hi Peter, Dave,
>
> this patch set is a follow up to the discussion:
> https://lkml.kernel.org/r/20160804142853.GO6862%20()%20twins%20!%20programming%20!%20kicks-ass%20!%20net
> It turned out to be simpler than what we discussed.
>
> Patches 1-3 is bpf-side prep for the main patch 4
> that adds bpf program as an overflow_handler to sw and hw perf_events.
> Peter, please review.
>
> Patches 5 and 6 are examples from myself and Brendan.
>
> v1-v2: fixed issues spotted by Peter and Daniel.

Thanks Alexei!

Tested-by: Brendan Gregg <bgregg@netflix.com>

Brendan
