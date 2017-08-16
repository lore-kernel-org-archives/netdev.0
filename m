From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 15 Aug 2017 19:21:16 -0700
Message-ID: <CA+55aFy_6fGAe-0vsuu8tbvuAz661=1YwB6CiS+BU04yUjmpGA@mail.gmail.com>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815.175219.753462032002961032.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 5:52 PM, David Miller <davem@davemloft.net> wrote:
>
> dingtianhong (4):
>       PCI: Disable PCIe Relaxed Ordering if unsupported
>       PCI: Disable Relaxed Ordering for some Intel processors
>       PCI: Disable Relaxed Ordering Attributes for AMD A1100
>       PCI: fix oops when try to find Root Port for a PCI device

I would *really* have liked to see an ack on these from Bjorn Helgaas.
Was he even cc'd?

And while singling those commits out, I would also really have liked
to see an actual name there.

The name exists in the sign-off chain:

    Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

but for some reason not in the actual commit author data, where it's
just "dingtianhong".

Pulled, but slightly unhappy.

                    Linus
