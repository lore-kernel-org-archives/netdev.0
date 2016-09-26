From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: drop unused fields from struct brcmf_pub
Date: Mon, 26 Sep 2016 17:51:25 +0000 (UTC)
Message-ID: <20160926175125.C01A76159A@smtp.codeaurora.org>
References: <20160923132759.21875-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        Colin Ian King <colin.king@canonical.com>,
        linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160923132759.21875-1-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> They seem to be there from the first day. We calculate these values but
> never use them.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Patch applied to wireless-drivers-next.git, thanks.

2df86ad959c9 brcmfmac: drop unused fields from struct brcmf_pub

-- 
https://patchwork.kernel.org/patch/9348103/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
