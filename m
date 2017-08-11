From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3,06/20] brcm80211: constify usb_device_id
Date: Fri, 11 Aug 2017 13:54:15 +0000 (UTC)
Message-ID: <20170811135415.95798602BE@smtp.codeaurora.org>
References: <ff83342cc9413d79ba18e05b2cb0b53bff338b2f.1502428689.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, chi-hsien.lin@cypress.com,
        wsa-dev@sang-engineering.com, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ff83342cc9413d79ba18e05b2cb0b53bff338b2f.1502428689.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

> usb_device_id are not supposed to change at runtime. All functions
> working with usb_device_id provided by <linux/usb.h> work with
> const usb_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

a67b133b9da5 brcm80211: constify usb_device_id

-- 
https://patchwork.kernel.org/patch/9894975/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
