From: Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH RFC v3 0/4] Add cross-compilation support to eBPF samples
Date: Tue, 5 Sep 2017 20:27:01 -0700
Message-ID: <CAJWu+op+mJV_Q2ss3Zss+GatmQHYT9GcZrs_YdYHZGCwp2zkNA@mail.gmail.com>
References: <20170903182326.30547-1-joelaf@google.com> <20170906032420.3bkvyz4p3wu2hyvy@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        "open list:BPF (Safe dynamic programs and tools)"
        <netdev@vger.kernel.org>, kernel-team@android.com,
        Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906032420.3bkvyz4p3wu2hyvy@ast-mbp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Tue, Sep 5, 2017 at 8:24 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sun, Sep 03, 2017 at 11:23:21AM -0700, Joel Fernandes wrote:
>> These patches fix issues seen when cross-compiling eBPF samples on arm64.
>> Compared to [1], I dropped the controversial inline-asm patch pending further
>> discussion on the right way to do it. However these patches are still a step in
>> the right direction and I wanted them to get in before the more controversial
>> bit.
>
> All patches in this set look good to me.
> When you repost without changes after net-next reopens pls keep my:
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks a lot! will do.

Regards,
Joel
