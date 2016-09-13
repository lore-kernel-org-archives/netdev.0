From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: ath10k: remove unused variable ar_pci
Date: Tue, 13 Sep 2016 14:25:28 +0200
Message-ID: <ab838c70bd944270ac482115c9194223@euamsexm01a.eu.qualcomm.com>
References: <20160905133802.18755-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160905133802.18755-1-chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Trival fix to remove unused variable ar_pci in ath10k_pci_tx_pipe_cleanup
> when building with W=1:
> drivers/net/wireless/ath/ath10k/pci.c:1696:21: warning: variable
> 'ar_pci' set but not used [-Wunused-but-set-variable]
> 
> Signed-off-by: Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks, 1 patch applied to ath-next branch of ath.git:

214d55394481 ath10k: remove unused variable ar_pci

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9313963/
