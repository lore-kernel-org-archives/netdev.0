From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bpf samples: fix compiler errors with sockex2 and
 sockex3
Date: Tue, 27 Sep 2016 03:49:10 -0400 (EDT)
Message-ID: <20160927.034910.2028580268696548096.davem@davemloft.net>
References: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, mpe@ellerman.id.au, ast@fb.com,
        daniel@iogearbox.net, ananth@in.ibm.com
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933305AbcI0HtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:49:14 -0400
In-Reply-To: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Sat, 24 Sep 2016 02:10:04 +0530

> These samples fail to compile as 'struct flow_keys' conflicts with
> definition in net/flow_dissector.h. Fix the same by renaming the
> structure used in the sample.
> 
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied to net-next.
