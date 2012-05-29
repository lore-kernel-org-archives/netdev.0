From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls (after
 pci_enable_device) fails
Date: Wed, 30 May 2012 05:04:57 +0530
Message-ID: <CAHdPZaOsMKHzT_JGnHtJE11ibtzb-hbHVp=tmuv_nL6Dnamwyw@mail.gmail.com>
References: <1338333250-11974-1-git-send-email-devendra.aaru@gmail.com>
	<20120529.191810.2141710455829509698.davem@davemloft.net>
	<CAHdPZaMfSKRzT4MN-5g3c1bOah4CB80aWyVhGKu1Z5AXTj2uTw@mail.gmail.com>
	<20120529.192438.1186076504142998357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120529.192438.1186076504142998357.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

On Wed, May 30, 2012 at 4:54 AM, David Miller <davem@davemloft.net> wrote:
> From: "devendra.aaru" <devendra.aaru@gmail.com>
> Date: Wed, 30 May 2012 04:52:08 +0530
>
>> Hello David,
>>
>>
>> OK, so may i put these two changes into one and send it? or you want
>> it to be two patches?
>
> It's up to you.

OK, i will be sending two patches shortly(with sequence numbers (git
format-patch -s -n)).

This time i have done compile testing and got no warnings.

Thanks,
Devendra.
