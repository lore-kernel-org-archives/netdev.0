From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bpf: cgroup: fix documentation of
 __cgroup_bpf_update()
Date: Tue, 29 Nov 2016 19:52:45 -0500 (EST)
Message-ID: <20161129.195245.2190938386692724540.davem@davemloft.net>
References: <1480338664-22616-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        roszenrami@gmail.com, cgroups@vger.kernel.org
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbcK3Awr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:52:47 -0500
In-Reply-To: <1480338664-22616-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Mon, 28 Nov 2016 14:11:04 +0100

> There's a 'not' missing in one paragraph. Add it.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> Reported-by: Rami Rosen <roszenrami@gmail.com>
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")

Applied, thanks.
