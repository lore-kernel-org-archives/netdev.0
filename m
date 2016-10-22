From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add BPF numa id helper
Date: Sat, 22 Oct 2016 16:52:26 -0400 (EDT)
Message-ID: <20161022.165226.1575235148081585915.davem@davemloft.net>
References: <cover.1477002095.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756006AbcJVUw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 16:52:28 -0400
In-Reply-To: <cover.1477002095.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 21 Oct 2016 00:30:25 +0200

> This patch set adds a helper for retrieving current numa node
> id and a test case for SO_REUSEPORT.

Series applied.
