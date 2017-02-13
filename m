From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v4 0/3] Miscellaneous fixes for BPF (perf tree)
Date: Mon, 13 Feb 2017 09:42:31 +0800
Message-ID: <3c82d8ea-86a0-05d9-97f4-5e91a10e66b2@huawei.com>
References: <20170208202744.16274-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208202744.16274-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/2/9 4:27, Mickaël Salaün wrote:
> This series brings some fixes and small improvements to the BPF samples.
>
> This is intended for the perf tree and apply on 7a5980f9c006 ("tools lib bpf:
> Add missing header to the library").
>
> Changes since v3:
> * remove applied patch 1/5
> * remove patch 2/5 on bpf_load_program() as requested by Wang Nan
>
> Changes since v2:
> * add this cover letter
>
> Changes since v1:
> * exclude patches not intended for the perf tree
>
> Regards,
>
> Mickaël Salaün (3):
>    samples/bpf: Ignore already processed ELF sections
>    samples/bpf: Reset global variables
>    samples/bpf: Add missing header
>
>   samples/bpf/bpf_load.c     | 7 +++++++
>   samples/bpf/tracex5_kern.c | 1 +
>   2 files changed, 8 insertions(+)
>
Looks good to me.

Thank you.
