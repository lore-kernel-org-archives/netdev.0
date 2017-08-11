From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Minor fix in bpf_convert_ctx_access
Date: Fri, 11 Aug 2017 14:59:39 -0700 (PDT)
Message-ID: <20170811.145939.1084649013473000047.davem@davemloft.net>
References: <cover.1502468639.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753581AbdHKV7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:59:40 -0400
In-Reply-To: <cover.1502468639.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 11 Aug 2017 18:31:23 +0200

> First one was found while trying to compile the kernel
> with !CONFIG_NET_RX_BUSY_POLL.

Series applied, thanks Daniel.
