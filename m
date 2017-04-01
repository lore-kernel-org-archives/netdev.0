From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] Make EN2 pin optional in the TRF7970A driver
Date: Sun, 2 Apr 2017 00:35:05 +0200
Message-ID: <20170401223353.GH22034@zurbaran.ger.intel.com>
References: <1486444924-18444-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
To: Heiko Schocher <hs@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486444924-18444-1-git-send-email-hs@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Heiko,

On Tue, Feb 07, 2017 at 06:22:04AM +0100, Heiko Schocher wrote:
> From: Guan Ben <ben.guan@cn.bosch.com>
> 
> Make the EN2 pin optional. This is useful for boards,
> which have this pin fix wired, for example to ground.
> 
> Signed-off-by: Guan Ben <ben.guan@cn.bosch.com>
> Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
> Signed-off-by: Heiko Schocher <hs@denx.de>
> 
> ---
> 
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
>  drivers/nfc/trf7970a.c                             | 26 ++++++++++++----------
>  2 files changed, 16 insertions(+), 14 deletions(-)
Applied to nfc-next, thanks.

Cheers,
Samuel.
