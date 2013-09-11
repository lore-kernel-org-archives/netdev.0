From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] bcm63xx_enet: remove deprecated IRQF_DISABLED
Date: Wed, 11 Sep 2013 10:05:50 +0900
Message-ID: <003101ceae8b$0e6dff20$2b49fd60$%han@samsung.com>
References: <1378537010-7128-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org, joe@perches.com,
	mbizon@freebox.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: 'Michael Opdenacker' <michael.opdenacker@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1378537010-7128-1-git-send-email-michael.opdenacker@free-electrons.com>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 07, 2013 3:57 PM, Michael Opdenacker wrote:
> 
> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/broadcom/bcm63xx_enet.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Reviewed-by: Jingoo Han <jg1.han@samsung.com>

Best regards,
Jingoo Han

> ---
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
