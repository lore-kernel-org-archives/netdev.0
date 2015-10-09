From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH] mwifiex: fix a comment typo
Date: Fri, 9 Oct 2015 11:37:49 +0000
Message-ID: <1d4ac22c01e9451f949c1df5343c2229@SC-EXCH04.marvell.com>
References: <53a87c6aae6bae712c079bf17ed27d0f1b381016.1443948331.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53a87c6aae6bae712c079bf17ed27d0f1b381016.1443948331.git.geliangtang@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Geliang Tang [mailto:geliangtang@163.com]
> Sent: Sunday, October 04, 2015 2:17 PM
> To: Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo
> Cc: Geliang Tang; linux-wireless@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] mwifiex: fix a comment typo
> 
> Just fix a typo in the code comment.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  drivers/net/wireless/mwifiex/cfg80211.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/cfg80211.c
> b/drivers/net/wireless/mwifiex/cfg80211.c
> index 30cbafb..b7ac45f 100644
> --- a/drivers/net/wireless/mwifiex/cfg80211.c
> +++ b/drivers/net/wireless/mwifiex/cfg80211.c
> @@ -2374,7 +2374,7 @@ mwifiex_cfg80211_leave_ibss(struct wiphy *wiphy,
> struct net_device *dev)
>   * CFG802.11 operation handler for scan request.
>   *
>   * This function issues a scan request to the firmware based upon
> - * the user specified scan configuration. On successfull completion,
> + * the user specified scan configuration. On successful completion,
>   * it also informs the results.
>   */
>  static int
> --
> 2.5.0
> 

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
