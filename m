From: Jiri Slaby <jslaby@suse.cz>
Subject: 3.10-stable commits missing in 3.12-stable
Date: Fri, 03 Apr 2015 12:22:02 +0200
Message-ID: <551E69CA.4040603@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: David Miller <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	stable <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35788 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbbDCKWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 06:22:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am crawling through commits which are in 3.10-stable but are not in
3.12-stable. Could you either ACK them so that I can pick them or
include them in the next stable NETWORKING patches, please?

=========================

Subject: net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()

From: Wei Yang <weiyang@linux.vnet.ibm.com>

[ Upstream commit befdf8978accecac2e0739e6b5075afc62db37fe ]

=========================

Subject: net: fix sparse warning in sk_dst_set()

From: Eric Dumazet <edumazet@google.com>

[ Upstream commit 5925a0555bdaf0b396a84318cbc21ba085f6c0d3 ]

=========================

Subject: net: mvneta: Fix big endian issue in mvneta_txq_desc_csum()

From: Thomas Fitzsimmons <fitzsim@fitzsim.org>

[ Upstream commit 0a1985879437d14bda8c90d0dae3455c467d7642 ]

=========================

Subject: dns_resolver: Null-terminate the right string

From: Ben Hutchings <ben@decadent.org.uk>

[ Upstream commit 640d7efe4c08f06c4ae5d31b79bd8740e7f6790a ]

=========================

Subject: core, nfqueue, openvswitch: Orphan frags in skb_zerocopy and
handle errors

From: Zoltan Kiss <zoltan.kiss@citrix.com>

commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.

=========================

Subject: net: mvneta: increase the 64-bit rx/tx stats out of the hot path

From: willy tarreau <w@1wt.eu>

commit dc4277dd41a80fd5f29a90412ea04bc3ba54fbf1 upstream.

=========================

Subject: net: mvneta: use per_cpu stats to fix an SMP lock up

From: willy tarreau <w@1wt.eu>

commit 74c41b048db1073a04827d7f39e95ac1935524cc upstream.

=========================

Subject: net: mvneta: do not schedule in mvneta_tx_timeout

From: willy tarreau <w@1wt.eu>

commit 290213667ab53a95456397763205e4b1e30f46b5 upstream.

=========================

Subject: net: mvneta: add missing bit descriptions for interrupt masks
and causes

From: willy tarreau <w@1wt.eu>

commit 40ba35e74fa56866918d2f3bc0528b5b92725d5e upstream.

=========================

Subject: net: mvneta: replace Tx timer with a real interrupt

From: willy tarreau <w@1wt.eu>

commit 71f6d1b31fb1f278a345a30a2180515adc7d80ae upstream.

=========================

Subject: ipv6: reallocate addrconf router for ipv6 address when lo
device up

From: Gao feng <gaofeng@cn.fujitsu.com>

[ Upstream commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 ]

=========================

thanks,
-- 
js
suse labs
