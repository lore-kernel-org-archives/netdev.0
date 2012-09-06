From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 9/10] drivers/net/wireless/rtlwifi/rtl8192de/phy.c: removes
 unnecessary semicolon
Date: Thu, 06 Sep 2012 11:49:30 -0500
Message-ID: <5048D41A.5060906@lwfinger.net>
References: <1346947757-10481-1-git-send-email-peter.senna@gmail.com> <1346947757-10481-10-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346947757-10481-10-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/06/2012 11:09 AM, Peter Senna Tschudin wrote:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
>
> removes unnecessary semicolon
>
> Found by Coccinelle: http://coccinelle.lip6.fr/
>
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>
> ---
>   drivers/net/wireless/rtlwifi/rtl8192de/phy.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
> --- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
> @@ -1314,7 +1314,7 @@ static void _rtl92d_phy_restore_rf_env(s
>   	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
>
>   	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "=====>\n");
> -	/*----Restore RFENV control type----*/ ;
> +	/*----Restore RFENV control type----*/
>   	switch (rfpath) {
>   	case RF90_PATH_A:
>   	case RF90_PATH_C:
>
>

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry
