From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 1/3] samples/bpf: Fix build breakage with
 map_perf_test_user.c
Date: Wed, 06 Apr 2016 16:01:59 -0400 (EDT)
Message-ID: <20160406.160159.1499495061682417737.davem@davemloft.net>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com, mpe@ellerman.id.au
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Mon,  4 Apr 2016 22:31:32 +0530

> Building BPF samples is failing with the below error:
 ...
> Fix this by including the necessary header file.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied.
