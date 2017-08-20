From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] BPF inline improvements
Date: Sat, 19 Aug 2017 21:56:51 -0700 (PDT)
Message-ID: <20170819.215651.731190886787905988.davem@davemloft.net>
References: <cover.1503104831.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdHTE4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 00:56:52 -0400
In-Reply-To: <cover.1503104831.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 19 Aug 2017 03:12:44 +0200

> First one makes htab inlining more robust wrt future jits and
> second one inlines map in map lookups through map_gen_lookup()
> callback.

Series applied, thanks Daniel.
