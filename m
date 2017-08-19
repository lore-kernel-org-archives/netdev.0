From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sat, 19 Aug 2017 13:48:43 -0700
Message-ID: <9d77730f-c6a8-b337-599e-5919207a7e0a@fb.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
 <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com>
 <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/19/17 12:59 PM, Shubham Bansal wrote:
> not be able to compare them like kees this week.
> Does that sound good?

yeah. that's fine. I was more interested in selftests/.../test_progs
numbers before/after, since they're more representative of real world
performance vs test_bpf.ko

> Thats right. But still an improvement I guess. I think I discussed it
> with Daniel and I thought, I should get this patch reach mainstream
> first then I can improve on it.

agree. To me the patch looks ready to land.
