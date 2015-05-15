From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_bpf: fix sparse warnings
Date: Thu, 14 May 2015 22:47:44 -0400 (EDT)
Message-ID: <20150514.224744.226913495439143677.davem@davemloft.net>
References: <1431574839-7099-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, fengguang.wu@intel.com,
	daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422886AbbEOCrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:47:46 -0400
In-Reply-To: <1431574839-7099-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 13 May 2015 20:40:39 -0700

> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> 
> Fix several sparse warnings like:
> lib/test_bpf.c:1824:25: sparse: constant 4294967295 is so big it is long
> lib/test_bpf.c:1878:25: sparse: constant 0x0000ffffffff0000 is so big it is long
> 
> Fixes: cffc642d93f9 ("test_bpf: add 173 new testcases for eBPF")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
