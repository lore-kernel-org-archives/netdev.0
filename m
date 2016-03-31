From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 1/4] samples/bpf: Fix build breakage with
 map_perf_test_user.c
Date: Thu, 31 Mar 2016 12:19:07 -0700
Message-ID: <56FD782B.1020005@fb.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FD61B6.9000102@fb.com> <20160331184602.GC17907@naverao1-tp.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160331184602.GC17907@naverao1-tp.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/16 11:46 AM, Naveen N. Rao wrote:
>> It's failing this way on powerpc? Odd.
> This fails for me on x86_64 too -- RHEL 7.1.

indeed. fails on centos 7.1, whereas centos 6.7 is fine.
