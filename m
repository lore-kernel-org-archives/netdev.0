From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 2/2] iproute2: add support for invisible qdisc
 dumping
Date: Tue, 14 Mar 2017 16:38:26 -0700
Message-ID: <20170314163826.62aa27e1@xeon-e3>
References: <alpine.LSU.2.20.1703081303490.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33544 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750860AbdCNXz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 19:55:56 -0400
Received: by mail-pg0-f42.google.com with SMTP id n190so835983pga.0
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 16:55:55 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.20.1703081303490.31814@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Mar 2017 13:04:42 +0100 (CET)
Jiri Kosina <jikos@kernel.org> wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
> kernel to perform 'full qdisc dump', as for historical reasons some of the 
> default qdiscs are being hidden by the kernel.
> 
> The command syntax is being extended by voluntary 'invisible' argument to
> 'tc qdisc show'.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Applied to net-next thanks.
