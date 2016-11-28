From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] BPF cleanups and misc updates
Date: Sun, 27 Nov 2016 20:39:31 -0500 (EST)
Message-ID: <20161127.203931.1180301140411528998.davem@davemloft.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbcK1Bjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 20:39:33 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 26 Nov 2016 01:28:03 +0100

> This patch set adds couple of cleanups in first few patches,
> exposes owner_prog_type for array maps as well as mlocked mem
> for maps in fdinfo, allows for mount permissions in fs and
> fixes various outstanding issues in selftests and samples.

Series applied, thanks Daniel.
