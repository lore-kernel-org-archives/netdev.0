From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Fix typo in NF_CONNTRACK Kconfig option
 description
Date: Mon, 16 Jan 2017 14:27:43 +0100
Message-ID: <20170116132743.GA21047@salvia>
References: <20170109222417.GA18253@sophia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: William Breathitt Gray <vilhelm.gray@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55912 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751602AbdAPN1s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 08:27:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 481D2392E31
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 14:27:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3380AA7BF8
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 14:27:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F14A0201DE
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 14:27:44 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170109222417.GA18253@sophia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 05:24:18PM -0500, William Breathitt Gray wrote:
> The NF_CONNTRACK Kconfig option description makes an incorrect reference
> to the "meta" expression where the "ct" expression would be correct.This
> patch fixes the respective typographical error.

Applied, thanks.
