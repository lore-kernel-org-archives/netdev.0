From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 2/17]
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1932:17: sparse: incorrect
 type in initializer (different base types)
Date: Thu, 13 Dec 2012 08:30:56 +0800
Message-ID: <50c921c0.P8eOXiZ2XaKTYc0p%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42952 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793Ab2LMAbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 19:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   520dfe3a3645257bf83660f672c47f8558f3d4c4
commit: 5216562a2ccd037d0eb85a2e8bbfd6315e3f1bb5 [2/17] bna: Tx and Rx Optimizations


sparse warnings:

drivers/net/ethernet/brocade/bna/bna_tx_rx.c:283:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:299:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:299:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:299:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:315:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:315:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:315:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:317:21: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:317:21:    expected unsigned short [unsigned] [usertype] handle
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:317:21:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:330:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:330:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:330:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:345:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:345:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:345:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:362:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:362:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:362:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:368:42: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:368:42:    expected unsigned int [unsigned] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:368:42:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:385:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:385:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:385:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:400:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:400:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:400:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:402:19: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:402:19:    expected unsigned short [unsigned] [usertype] size
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:402:19:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:417:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:417:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:417:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:422:33: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:422:33:    expected unsigned int [unsigned] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:422:33:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:436:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:436:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:436:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:723:17: sparse: cast to restricted __be16
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:723:17: sparse: cast to restricted __be16
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:723:17: sparse: cast to restricted __be16
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:723:17: sparse: cast to restricted __be16
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1650:33: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1650:33:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1650:33:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25:    expected unsigned short [unsigned] [usertype] pages
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25:    expected unsigned short [unsigned] [usertype] page_sz
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1664:25:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1666:61: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1666:61:    expected unsigned short [unsigned] [usertype] rx_buffer_size
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1666:61:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25:    expected unsigned short [unsigned] [usertype] pages
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25:    expected unsigned short [unsigned] [usertype] page_sz
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1672:25:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1676:61: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1676:61:    expected unsigned short [unsigned] [usertype] rx_buffer_size
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1676:61:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17:    expected unsigned short [unsigned] [usertype] pages
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17:    expected unsigned short [unsigned] [usertype] page_sz
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1684:17:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1691:54: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1691:54:    expected unsigned short [unsigned] [usertype] msix_index
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1691:54:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1702:44: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1702:44:    expected unsigned int [unsigned] [usertype] coalescing_timeout
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1702:44:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1704:43: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1704:43:    expected unsigned int [unsigned] [usertype] inter_pkt_timeout
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1704:43:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1406:1: sparse: symbol 'bna_rx_sm_stop_wait_entry' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1459:1: sparse: symbol 'bna_rx_sm_rxf_stop_wait_entry' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1492:1: sparse: symbol 'bna_rx_sm_started_entry' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1557:1: sparse: symbol 'bna_rx_sm_cleanup_wait_entry' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1562:1: sparse: symbol 'bna_rx_sm_cleanup_wait' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1741:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1741:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1741:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1926:9: sparse: cast to restricted __be32
+ drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1932:17: sparse: incorrect type in initializer (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1932:17:    expected unsigned long long [unsigned] [usertype] tmp_addr
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1932:17:    got restricted __be64 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1964:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1970:17: sparse: incorrect type in initializer (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1970:17:    expected unsigned long long [unsigned] [usertype] tmp_addr
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1970:17:    got restricted __be64 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2185:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2189:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:2194:27: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3168:33: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3168:33:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3168:33:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17:    expected unsigned short [unsigned] [usertype] pages
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17:    expected unsigned short [unsigned] [usertype] page_sz
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3177:17:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3184:54: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3184:54:    expected unsigned short [unsigned] [usertype] msix_index
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3184:54:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3194:44: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3194:44:    expected unsigned int [unsigned] [usertype] coalescing_timeout
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3194:44:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3196:43: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3196:43:    expected unsigned int [unsigned] [usertype] inter_pkt_timeout
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3196:43:    got restricted __be32 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3201:33: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3201:33:    expected unsigned short [unsigned] [usertype] vlan_id
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3201:33:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3217:29: sparse: incorrect type in assignment (different base types)
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3217:29:    expected unsigned short [unsigned] [usertype] num_entries
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3217:29:    got restricted __be16 [usertype] <noident>
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: cast to restricted __be32
+ drivers/net/ethernet/brocade/bna/bna_tx_rx.c:3260:9: sparse: too many warnings

vim +1932 drivers/net/ethernet/brocade/bna/bna_tx_rx.c

f3bd5173 Rasesh Mody 2011-08-08  1920  	rxq->qpt.page_size = page_size;
f3bd5173 Rasesh Mody 2011-08-08  1921  
f3bd5173 Rasesh Mody 2011-08-08  1922  	rxq->rcb->sw_qpt = (void **) swqpt_mem->kva;
5216562a Rasesh Mody 2012-12-11  1923  	rxq->rcb->sw_q = page_mem->kva;
5216562a Rasesh Mody 2012-12-11  1924  
5216562a Rasesh Mody 2012-12-11  1925  	kva = page_mem->kva;
5216562a Rasesh Mody 2012-12-11 @1926  	BNA_GET_DMA_ADDR(&page_mem->dma, dma);
f3bd5173 Rasesh Mody 2011-08-08  1927  
f3bd5173 Rasesh Mody 2011-08-08  1928  	for (i = 0; i < rxq->qpt.page_count; i++) {
5216562a Rasesh Mody 2012-12-11  1929  		rxq->rcb->sw_qpt[i] = kva;
5216562a Rasesh Mody 2012-12-11  1930  		kva += PAGE_SIZE;
5216562a Rasesh Mody 2012-12-11  1931  
5216562a Rasesh Mody 2012-12-11 @1932  		BNA_SET_DMA_ADDR(dma, &bna_dma);
f3bd5173 Rasesh Mody 2011-08-08  1933  		((struct bna_dma_addr *)rxq->qpt.kv_qpt_ptr)[i].lsb =
5216562a Rasesh Mody 2012-12-11  1934  			bna_dma.lsb;
f3bd5173 Rasesh Mody 2011-08-08  1935  		((struct bna_dma_addr *)rxq->qpt.kv_qpt_ptr)[i].msb =

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
