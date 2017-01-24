From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Misc BPF improvements
Date: Tue, 24 Jan 2017 14:49:40 -0500 (EST)
Message-ID: <20170124.144940.1595292199279245934.davem@davemloft.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXTtm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:49:42 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 24 Jan 2017 01:06:25 +0100

> This series adds various misc improvements to BPF, f.e. allowing
> skb_load_bytes() helper to be used with filter/reuseport programs
> to facilitate programming, test cases for program tag, etc. For
> details, please see individual patches.

Series applied, thanks.
