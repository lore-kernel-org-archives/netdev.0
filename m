From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/8] irda: w83977af_ir: Remove unnecessary blank lines
Date: Fri, 25 Nov 2016 13:31:50 +0300
Message-ID: <ea272463-7af8-87d5-235c-631d280714b9@cogentembedded.com>
References: <cover.1480014088.git.joe@perches.com>
 <27a5cbfc2f59a978ad84ff19ddd76d6a333adfba.1480014088.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <27a5cbfc2f59a978ad84ff19ddd76d6a333adfba.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/24/2016 10:10 PM, Joe Perches wrote:

> These just add unnecessary vertical whitespace.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/irda/w83977af_ir.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
> index 4ad91f4f867f..5aa61413aea8 100644
> --- a/drivers/net/irda/w83977af_ir.c
> +++ b/drivers/net/irda/w83977af_ir.c
[...]
> @@ -553,6 +552,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
>  static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
>  {
>  	__u8 set;
> +
>  	pr_debug("%s(), len=%d\n", __func__, self->tx_buff.len);
>
>  	/* Save current set */

    Removing, really? :-)

MBR, Sergei
