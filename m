From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: ath9k: remove useless variable assignment in ath_mci_intr()
Date: Wed, 28 Jun 2017 18:57:07 +0200
Message-ID: <36c24b8f739a44adbad3a2b5487cc184@euamsexm01a.eu.qualcomm.com>
References: <20170626232658.GA17483@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
To: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170626232658.GA17483@embeddedgus>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org> wrote:

> Value assigned to variable offset at line 551 is overwritten at line 562,
> before it can be used. This makes such variable assignment useless.
> 
> Addresses-Coverity-ID: 1226941
> Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
> Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>

Patch applied to ath-next branch of ath.git, thanks.

6788a3832c70 ath9k: remove useless variable assignment in ath_mci_intr()

-- 
https://patchwork.kernel.org/patch/9810609/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
