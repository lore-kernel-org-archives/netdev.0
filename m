From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf_setsockopts return value
Date: Thu, 24 Aug 2017 18:24:18 -0700 (PDT)
Message-ID: <20170824.182418.82619854680196124.davem@davemloft.net>
References: <20170824224821.31672-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brakmo@fb.com, ncardwell@google.com, cgallek@google.com,
        netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753627AbdHYBYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:24:18 -0400
In-Reply-To: <20170824224821.31672-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 24 Aug 2017 15:48:21 -0700

> This patch fixes a bug causing any sock operations to always return EINVAL.
> 
> Fixes: a5192c52377e ("bpf: fix to bpf_setsockops").
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Craig Gallek <kraig@google.com>

Applied.
