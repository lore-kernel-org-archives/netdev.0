From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] bpf: Rebuild bpf.o for any dependency
 update
Date: Wed, 15 Feb 2017 12:16:28 -0500 (EST)
Message-ID: <20170215.121628.715725164635471113.davem@davemloft.net>
References: <20170211222023.19920-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        wangnan0@huawei.com, netdev@vger.kernel.org
To: mic@digikod.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751840AbdBORQa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:16:30 -0500
In-Reply-To: <20170211222023.19920-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mickaël Salaün <mic@digikod.net>
Date: Sat, 11 Feb 2017 23:20:23 +0100

> This is needed to force a rebuild of bpf.o when one of its dependencies
> (e.g. uapi/linux/bpf.h) is updated.
> 
> Add a phony target.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>

Applied.
