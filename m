From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: fix build error in devmap helper calls
Date: Mon, 17 Jul 2017 22:48:27 -0700 (PDT)
Message-ID: <20170717.224827.905776500726773335.davem@davemloft.net>
References: <20170718045648.7398.68557.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdGRFsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 01:48:31 -0400
In-Reply-To: <20170718045648.7398.68557.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 17 Jul 2017 21:56:48 -0700

> Initial patches missed case with CONFIG_BPF_SYSCALL not set.
> 
> Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
> Fixes: 97f91a7cf04f ("bpf: add bpf_redirect_map helper routine")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Applied, thanks.
