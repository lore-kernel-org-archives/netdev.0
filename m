From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 0/3] Miscellaneous fixes for BPF (perf tree)
Date: Fri, 10 Feb 2017 13:28:14 -0800
Message-ID: <CAPWQB7E74oF9Z3yccaq12bjVtap8jize48S=GO+XrMzwJB0y2A@mail.gmail.com>
References: <20170208202744.16274-1-mic@digikod.net> <20170210174234.GH2162@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Wang Nan <wangnan0@huawei.com>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170210174234.GH2162@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10 February 2017 at 09:42, Arnaldo Carvalho de Melo <acme@redhat.com> wrote:
> Em Wed, Feb 08, 2017 at 09:27:41PM +0100, Mickaël Salaün escreveu:
>> This series brings some fixes and small improvements to the BPF samples.
>>
>> This is intended for the perf tree and apply on 7a5980f9c006 ("tools lib bpf:
>> Add missing header to the library").
>
> Wang, are you ok with this series? Joe?

The changes look good to me. I also tried tracex5 and it seems to work fine.
