From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cgroup: Fix CGROUP_BPF config
Date: Sat, 17 Dec 2016 21:43:04 -0500 (EST)
Message-ID: <20161217.214304.507677344809331242.davem@davemloft.net>
References: <8d48c3940f8d0275da6398ea5bcef14e20233db5.1481905995.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@zonque.org,
        netdev@vger.kernel.org
To: luto@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759477AbcLRCnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:43:25 -0500
In-Reply-To: <8d48c3940f8d0275da6398ea5bcef14e20233db5.1481905995.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 16 Dec 2016 08:33:45 -0800

> CGROUP_BPF depended on SOCK_CGROUP_DATA which can't be manually
> enabled, making it rather challenging to turn CGROUP_BPF on.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Applied, thanks.
