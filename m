From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/4] lib/test_bpf: Add test to check for result of
 32-bit add that overflows
Date: Wed, 06 Apr 2016 16:48:23 -0400 (EDT)
Message-ID: <20160406.164823.1913463510545411329.davem@davemloft.net>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
	<5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
	<9c799e59e71c022271c6287769d45a32f29de4bd.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com, mpe@ellerman.id.au, paulus@samba.org
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9c799e59e71c022271c6287769d45a32f29de4bd.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Tue,  5 Apr 2016 15:32:55 +0530

> BPF_ALU32 and BPF_ALU64 tests for adding two 32-bit values that results in
> 32-bit overflow.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied.
