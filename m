From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: align usage of sh_eth_modify() with rest of
 driver
Date: Wed, 1 Feb 2017 18:55:48 +0300
Message-ID: <ba671d9f-6f2f-0c4a-b94c-a885d54f39dc@cogentembedded.com>
References: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
 <20170201144155.17123-2-niklas.soderlund+renesas@ragnatech.se>
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
In-Reply-To: <20170201144155.17123-2-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 02/01/2017 05:41 PM, Niklas Söderlund wrote:

> To be consistent with the rest of the driver when setting bits using
> sh_eth_modify() the same bit should also be cleared. This have no
> functional change and should have been done from the start.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

MBR, Sergei
