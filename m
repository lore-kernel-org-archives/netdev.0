From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] net: korina: remove deprecated IRQF_DISABLED
Date: Wed, 11 Sep 2013 10:00:49 +0900
Message-ID: <003001ceae8a$5b0ad700$11208500$%han@samsung.com>
References: <1378531257-5446-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, emilio@elopez.com.ar, mugunthanvnm@ti.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: 'Michael Opdenacker' <michael.opdenacker@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1378531257-5446-1-git-send-email-michael.opdenacker@free-electrons.com>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 07, 2013 2:21 PM, Michael Opdenacker wrote:
> 
> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/korina.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Reviewed-by: Jingoo Han <jg1.han@samsung.com>

Best regards,
Jingoo Han

> ---
>  drivers/net/ethernet/korina.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
