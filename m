From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] bfin_mac: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 17:09:58 +0900
Message-ID: <000101ceaf8f$795f5cc0$6c1e1640$%han@samsung.com>
References: <1378956943-3470-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, jiri@resnulli.us, mugunthanvnm@ti.com,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: 'Michael Opdenacker' <michael.opdenacker@free-electrons.com>,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1378956943-3470-1-git-send-email-michael.opdenacker@free-electrons.com>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 12, 2013 12:36 PM, Michael Opdenacker wrote:
> 
> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/adi/bfin_mac.c.
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Reviewed-by: Jingoo Han <jg1.han@samsung.com>

Best regards,
Jingoo Han

> ---
>  drivers/net/ethernet/adi/bfin_mac.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
