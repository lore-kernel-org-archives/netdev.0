From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Misc BPF cleanup
Date: Mon, 24 Apr 2017 16:20:38 -0400 (EDT)
Message-ID: <20170424.162038.2184445870186591568.davem@davemloft.net>
References: <20170424133108.31595-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: alexander@alemayhu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1174257AbdDXUUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:20:55 -0400
In-Reply-To: <20170424133108.31595-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Alemayhu <alexander@alemayhu.com>
Date: Mon, 24 Apr 2017 15:31:05 +0200

> while looking into making the Makefile in samples/bpf better handle O= I saw
> several warnings when running `make clean && make samples/bpf/`. This series
> reduces those warnings.

Series applied, thanks.
