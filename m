From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH net 2/4] lib/test_bpf: Add tests for unsigned BPF_JGT
Date: Tue, 5 Apr 2016 22:20:07 +0530
Message-ID: <20160405165007.GB15993@naverao1-tp.in.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
 <6b946d54d20d96052ce4f4baec308cdb20ace39a.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
 <5703E5C5.5060901@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5703E5C5.5060901@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/04/05 09:20AM, Alexei Starovoitov wrote:
> On 4/5/16 3:02 AM, Naveen N. Rao wrote:
> >Unsigned Jump-if-Greater-Than.
> >
> >Cc: Alexei Starovoitov <ast@fb.com>
> >Cc: Daniel Borkmann <daniel@iogearbox.net>
> >Cc: "David S. Miller" <davem@davemloft.net>
> >Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> >Cc: Michael Ellerman <mpe@ellerman.id.au>
> >Cc: Paul Mackerras <paulus@samba.org>
> >Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> 
> I think some of the tests already cover it, but extra tests are
> always great.
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
> I think the whole set belongs in net-next.
> Next time you submit the patches please say [PATCH net-next] in subject.
> [PATCH net] is for bugfixes only.

Ah, sure. Thanks for the review!

- Naveen
