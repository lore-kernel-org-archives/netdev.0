From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 3/3] samples/bpf: Enable powerpc support
Date: Wed, 06 Apr 2016 16:02:13 -0400 (EDT)
Message-ID: <20160406.160213.1279487084800637522.davem@davemloft.net>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
	<5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
	<28d2e09a7db94a0a71b3222b3e5ffacb0d4a8dd7.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com, mpe@ellerman.id.au
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <28d2e09a7db94a0a71b3222b3e5ffacb0d4a8dd7.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Mon,  4 Apr 2016 22:31:34 +0530

> Add the necessary definitions for building bpf samples on ppc.
> 
> Since ppc doesn't store function return address on the stack, modify how
> PT_REGS_RET() and PT_REGS_FP() work.
> 
> Also, introduce PT_REGS_IP() to access the instruction pointer.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied.
