From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/6] net: ethernet: renesas: ravb_main: test clock rate to
 avoid division by 0
Date: Thu, 3 Mar 2016 14:14:20 +0300
Message-ID: <56D81C8C.3070903@cogentembedded.com>
References: <1456958018-7849-1-git-send-email-wsa@the-dreams.de>
 <1456958018-7849-3-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>, linux-kernel@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456958018-7849-3-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/3/2016 1:33 AM, Wolfram Sang wrote:

> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
>
> The clk API may return 0 on clk_get_rate, so we should check the result before
> using it as a divisor.
>
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
