From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net 2/4] lib/test_bpf: Add tests for unsigned BPF_JGT
Date: Tue, 5 Apr 2016 09:20:21 -0700
Message-ID: <5703E5C5.5060901@fb.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
 <6b946d54d20d96052ce4f4baec308cdb20ace39a.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6b946d54d20d96052ce4f4baec308cdb20ace39a.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/5/16 3:02 AM, Naveen N. Rao wrote:
> Unsigned Jump-if-Greater-Than.
>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

I think some of the tests already cover it, but extra tests are
always great.
Acked-by: Alexei Starovoitov <ast@kernel.org>

I think the whole set belongs in net-next.
Next time you submit the patches please say [PATCH net-next] in subject.
[PATCH net] is for bugfixes only.
Thanks a bunch!
