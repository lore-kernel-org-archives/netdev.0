From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/4] lib/test_bpf: Add additional BPF_ADD tests
Date: Wed, 06 Apr 2016 16:48:28 -0400 (EDT)
Message-ID: <20160406.164828.1984846852338173494.davem@davemloft.net>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
	<5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
	<9b71e280481a9f84cd7dbb9e767fd08e6f4c0aef.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com, mpe@ellerman.id.au, paulus@samba.org
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670AbcDFUsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:48:31 -0400
In-Reply-To: <9b71e280481a9f84cd7dbb9e767fd08e6f4c0aef.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Tue,  5 Apr 2016 15:32:56 +0530

> Some of these tests proved useful with the powerpc eBPF JIT port due to
> sign-extended 16-bit immediate loads. Though some of these aspects get
> covered in other tests, it is better to have explicit tests so as to
> quickly tag the precise problem.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied.
