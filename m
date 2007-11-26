From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 31/59] drivers/net/ixgb: Add missing "space"
Date: Mon, 26 Nov 2007 15:16:11 -0800
Message-ID: <474B53BB.3030002@intel.com>
References: 1234567 <1195523331-15303-15-git-send-email-joe@perches.com> <1195523331-15303-16-git-send-email-joe@perches.com> <1195523331-15303-17-git-send-email-joe@perches.com> <1195523331-15303-18-git-send-email-joe@perches.com> <1195523331-15303-19-git-send-email-joe@perches.com> <1195523331-15303-20-git-send-email-joe@perches.com> <1195523331-15303-21-git-send-email-joe@perches.com> <1195523331-15303-22-git-send-email-joe@perches.com> <1195523331-15303-23-git-send-email-joe@perches.com> <1195523331-15303-24-git-send-email-joe@perches.com> <1195523331-15303-25-git-send-email-joe@perches.com> <1195523331-15303-26-git-send-email-joe@perches.com> <1195523331-15303-27-git-send-email-joe@perches.com> <1195523331-15303-28-git-send-email-joe@perches.com> <1195523331-15303-29-git-send-email-jo
 e@perches.com> <1195523331-15303-30-git-send-email-joe@perches.com> <1195523331-15303-31-git-send-email-joe@perches.com> <1195523331-15303-32-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9241 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756088AbXKZXQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 18:16:36 -0500
In-Reply-To: <1195523331-15303-32-git-send-email-joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ixgbe/ixgbe_common.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
> index 512e3b2..b7e50bc 100644
> --- a/drivers/net/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ixgbe/ixgbe_common.c
> @@ -950,7 +950,7 @@ s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
>  	u32 rmcs_reg;
>  
>  	if (packetbuf_num < 0 || packetbuf_num > 7)
> -		hw_dbg(hw, "Invalid packet buffer number [%d], expected range"
> +		hw_dbg(hw, "Invalid packet buffer number [%d], expected range "
>  		       "is 0-7\n", packetbuf_num);
>  
>  	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);

Jeff, please apply in case you didn't do so yet.

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Auke
