From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] eBPF JIT for PPC64
Date: Fri, 10 Jun 2016 22:47:55 -0700 (PDT)
Message-ID: <20160610.224755.1614979708956751311.davem@davemloft.net>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, mpe@ellerman.id.au, matt@ozlabs.org,
	kda@linux-powerpc.org, paulus@samba.org, ast@fb.com,
	daniel@iogearbox.net, ananth@in.ibm.com
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbcFKFr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 01:47:57 -0400
In-Reply-To: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Tue,  7 Jun 2016 19:02:17 +0530

> Please note that patch [2] is a pre-requisite for this patchset, and is
> not yet upstream.
 ...
> [1] http://thread.gmane.org/gmane.linux.kernel/2188694
> [2] http://thread.gmane.org/gmane.linux.ports.ppc.embedded/96514

Because of #2 I don't think I can take this directly into the networking
tree, right?

Therefore, how would you like this to be merged?
