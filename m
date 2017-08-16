From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 15 Aug 2017 20:03:48 -0700 (PDT)
Message-ID: <20170815.200348.2211153937269214873.davem@davemloft.net>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
        <CA+55aFy_6fGAe-0vsuu8tbvuAz661=1YwB6CiS+BU04yUjmpGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy_6fGAe-0vsuu8tbvuAz661=1YwB6CiS+BU04yUjmpGA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 19:21:16 -0700

> On Tue, Aug 15, 2017 at 5:52 PM, David Miller <davem@davemloft.net> wrote:
>>
>> dingtianhong (4):
>>       PCI: Disable PCIe Relaxed Ordering if unsupported
>>       PCI: Disable Relaxed Ordering for some Intel processors
>>       PCI: Disable Relaxed Ordering Attributes for AMD A1100
>>       PCI: fix oops when try to find Root Port for a PCI device
> 
> I would *really* have liked to see an ack on these from Bjorn Helgaas.
> Was he even cc'd?
> 
> And while singling those commits out, I would also really have liked
> to see an actual name there.
> 
> The name exists in the sign-off chain:
> 
>     Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> but for some reason not in the actual commit author data, where it's
> just "dingtianhong".
> 
> Pulled, but slightly unhappy.

Bjorn did review these changes, and certainly shaped the final result,
but indeed I should have gotten an explicit ACK from him.

I'll make sure I do so next time.
