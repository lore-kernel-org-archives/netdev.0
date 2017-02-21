From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] BPF fix with regards to unlocking
Date: Tue, 21 Feb 2017 13:32:15 -0500 (EST)
Message-ID: <20170221.133215.1243972672456810234.davem@davemloft.net>
References: <cover.1487688093.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, labbott@redhat.com, eric.dumazet@gmail.com,
        willemb@google.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751955AbdBUScS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:32:18 -0500
In-Reply-To: <cover.1487688093.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 21 Feb 2017 16:09:32 +0100

> This set fixes the issue Eric was reporting recently [1].
> First patch is a prerequisite discussed with Laura that is
> needed for the later fix in the second one. I've tested this
> extensively and it does not reproduce anymore on my side
> after the fix. Thanks & sorry about that!
> 
>   [1] https://www.spinics.net/lists/netdev/msg421877.html

Series applied, thanks Daniel.
