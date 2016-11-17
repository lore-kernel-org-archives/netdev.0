From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: print name of connect status event
Date: Thu, 17 Nov 2016 06:45:02 +0000 (UTC)
Message-ID: <20161117064502.0D0F5615D8@smtp.codeaurora.org>
References: <20161014074559.22962-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161014074559.22962-1-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> This simplifies debugging. Format %s (%u) comes from similar debugging
> message in brcmf_fweh_event_worker.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Patch applied to wireless-drivers-next.git, thanks.

e1c122d55f9e brcmfmac: print name of connect status event

-- 
https://patchwork.kernel.org/patch/9376147/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
