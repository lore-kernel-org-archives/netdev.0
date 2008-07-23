From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Subject: Re: [PATCH v3] net: sh_eth: Add support of SH7763 to sh_eth
Date: Wed, 23 Jul 2008 13:10:56 +0900
Message-ID: <4886AF50.3000707@renesas.com>
References: <485A3437.4010902@renesas.com> <4864840A.3060003@garzik.org>
 <48684011.5020201@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>,
	netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>,
	Linux-sh <linux-sh@vger.kernel.org>,
	Paul Mundt <lethal@linux-sh.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <48684011.5020201@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jeff.

Please pick up,  and apply  this patch to 2.6.27 queue too.

Best regards,
 Nobuhiro

Nobuhiro Iwamatsu wrote:
> Jeff Garzik wrote:
>> Nobuhiro Iwamatsu wrote:
>>> SH7763 has Ethernet core same as SH7710/SH7712.
>>> Positions of some registry are different, but the basic part is the same.
>>> I add support of ethernet of sh7763 to sh_eth.
>>>
>>> Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
>>> ---
>>>  drivers/net/Kconfig  |    4 +-
>>>  drivers/net/sh_eth.c |  202 ++++++++++++++++++++-----
>>>  drivers/net/sh_eth.h |  425 +++++++++++++++++++++++++++++++++++++-------------
>>>  3 files changed, 482 insertions(+), 149 deletions(-)
>> ACK but failed to apply
> 
> Sorry, I checked the patch, and corrected that the patch was able to be applied.
> Please apply.
> 
> Best regards,
>  Nobuhiro
> 
> ------->
> 
> SH7763 has Ethernet core same as SH7710/SH7712.
> Positions of some registry are different, but the basic part is the same.
> I add support of ethernet of sh7763 to sh_eth.
> 
> Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
> ---
>  drivers/net/Kconfig  |    4 +-
>  drivers/net/sh_eth.c |  202 ++++++++++++++++++++-----
>  drivers/net/sh_eth.h |  426 +++++++++++++++++++++++++++++++++++++-------------
>  3 files changed, 482 insertions(+), 150 deletions(-)

