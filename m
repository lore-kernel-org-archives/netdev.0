From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v4 0/3] Miscellaneous fixes for BPF (perf tree)
Date: Mon, 13 Feb 2017 18:27:33 -0200
Message-ID: <20170213202733.GB2112@redhat.com>
References: <20170208202744.16274-1-mic@digikod.net>
 <3c82d8ea-86a0-05d9-97f4-5e91a10e66b2@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3c82d8ea-86a0-05d9-97f4-5e91a10e66b2@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Feb 13, 2017 at 09:42:31AM +0800, Wangnan (F) escreveu:
> On 2017/2/9 4:27, Mickaël Salaün wrote:
> >Mickaël Salaün (3):
> >   samples/bpf: Ignore already processed ELF sections
> >   samples/bpf: Reset global variables
> >   samples/bpf: Add missing header
> >
> >  samples/bpf/bpf_load.c     | 7 +++++++
> >  samples/bpf/tracex5_kern.c | 1 +
> >  2 files changed, 8 insertions(+)
> >
> Looks good to me.
> 
> Thank you.

Thanks, applied, added Acked-by tags for you and Joe.

- Arnaldo
