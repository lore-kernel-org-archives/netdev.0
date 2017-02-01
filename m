From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: fix wakeup event reporting from MagicPacket
Date: Wed, 1 Feb 2017 18:56:48 +0300
Message-ID: <4436a62d-8856-e793-96f9-b265388046e2@cogentembedded.com>
References: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
 <20170201144155.17123-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170201144155.17123-3-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2017 05:41 PM, Niklas Söderlund wrote:

> If a link change interrupt happens along side the MagicPacket interrupt
> and the link change interrupt is ignored the interrupt handler will
> return and the wakeup event is not register. Fix this by moving the

    Registered?

> MagicPacket check before the link change check.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

MBR, Sergei
