From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Wed, 19 Jun 2013 00:50:05 -0700 (PDT)
Message-ID: <20130619.005005.2262835197239818334.davem@davemloft.net>
References: <201306190207.46832.sergei.shtylyov@cogentembedded.com>
	<CANqRtoRNnNuG_r+MW3Yb79jVK_iKm1bRTSvMhw1j4qsWZtphpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CANqRtoRNnNuG_r+MW3Yb79jVK_iKm1bRTSvMhw1j4qsWZtphpw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Wed, 19 Jun 2013 15:47:47 +0900

> Hi Sergei,
> 
> On Wed, Jun 19, 2013 at 7:07 AM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>> sh_eth_interrupt() uses the same Rx interrupt mask twice to check the interrupt
>> status register -- #define EESR_RX_CHECK  and use it instead.
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Thanks for the patch, nice to see that this driver is moving forward.
> 
> Can you please include information about which SoC / board this code
> has been tested on? As you know, the actual hardware that this driver
> is operating on is not very well documented, so at least having
> information about the SoC together with the commit message or patch
> may help in the future.

Sergei, please make this suggested change and resubmit this series, thank you.
