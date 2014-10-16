From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH] [trivial] treewide: Fix company name in module descriptions
Date: Thu, 16 Oct 2014 12:09:20 -0700
Message-ID: <CAMXMK6vGF9ZJHcM2k9qcXHDP-kOPNsuWHxDXh2Rxqp_m3YPFaQ@mail.gmail.com>
References: <1413472164-22366-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, mturquette@linaro.org,
	trivial@kernel.org, linus.walleij@linaro.org, gnurou@gmail.com,
	James Cliburn <jcliburn@gmail.com>, viresh.linux@gmail.com,
	inki.dae@samsung.com, dh09.lee@samsung.com, kgene.kim@samsung.com,
	rdunlap@infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413472164-22366-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2014 at 8:09 AM, Masanari Iida <standby24x7@gmail.com> wrote:
> This patch fix company name's spelling typo in module descriptions
> and a Kconfig.
>
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 72fb86b..c9946c6 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -48,7 +48,7 @@ MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
>
>  MODULE_AUTHOR("Jie Yang");
>  MODULE_AUTHOR("Qualcomm Atheros Inc., <nic-devel@qualcomm.com>");
> -MODULE_DESCRIPTION("Qualcom Atheros 100/1000M Ethernet Network Driver");
> +MODULE_DESCRIPTION("Qualcomm Atheros 100/1000M Ethernet Network Driver");
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(ATL1C_DRV_VERSION);
>

Acked-by: Chris Snook <chris.snook@gmail.com>
