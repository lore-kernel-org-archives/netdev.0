From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Minor BPF cleanups and digest
Date: Mon, 05 Dec 2016 15:33:26 -0500 (EST)
Message-ID: <20161205.153326.2127477025449017116.davem@davemloft.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbcLEUdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:33:31 -0500
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun,  4 Dec 2016 23:19:38 +0100

> First two patches are minor cleanups, and the third one adds
> a prog digest. For details, please see individual patches.
> After this one, I have a set with tracepoint support that makes
> use of this facility as well.

Series applied, thanks.
