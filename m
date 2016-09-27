From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bpf samples: update tracex5 sample to use
 __seccomp_filter
Date: Tue, 27 Sep 2016 03:49:18 -0400 (EDT)
Message-ID: <20160927.034918.1429109762920005486.davem@davemloft.net>
References: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
        <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
        <8e5ab9853508240e901260b1af36243c4d744083.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, mpe@ellerman.id.au, ast@fb.com,
        daniel@iogearbox.net, ananth@in.ibm.com
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933365AbcI0HtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:49:21 -0400
In-Reply-To: <8e5ab9853508240e901260b1af36243c4d744083.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Sat, 24 Sep 2016 02:10:05 +0530

> seccomp_phase1() does not exist anymore. Instead, update sample to use
> __seccomp_filter(). While at it, set max locked memory to unlimited.
> 
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Also applied to net-next, thanks.
