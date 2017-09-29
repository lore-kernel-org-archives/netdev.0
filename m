From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bpf: Extend bpf_{prog,map}_info
Date: Fri, 29 Sep 2017 06:17:36 +0100 (WEST)
Message-ID: <20170929.061736.771339359071316832.davem@davemloft.net>
References: <20170927213756.1254938-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdI2IV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 04:21:57 -0400
In-Reply-To: <20170927213756.1254938-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 27 Sep 2017 14:37:51 -0700

> This patch series adds more fields to bpf_prog_info and bpf_map_info.
> Please see individual patch for details.

Great to see progress in the area of eBPF introspection.

Series applied, thanks.
