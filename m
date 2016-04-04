From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2 net 2/3] samples/bpf: Use llc in PATH, rather than a
 hardcoded value
Date: Mon, 4 Apr 2016 10:24:16 -0700
Message-ID: <20160404172414.GA67762@ast-mbp.thefacebook.com>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
 <000e23c21f475e7106c74a83eb6226c4cb8d4a14.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <000e23c21f475e7106c74a83eb6226c4cb8d4a14.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2016 at 10:31:33PM +0530, Naveen N. Rao wrote:
> While at it, remove the generation of .s files and fix some typos in the
> related comment.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
