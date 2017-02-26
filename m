From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: rtl8192de: ix spelling mistake: "althougth" ->
 "although"
Date: Sun, 26 Feb 2017 10:57:56 -0600
Message-ID: <8f5d0d3b-b4ef-d9f4-50fa-e461760912fa@lwfinger.net>
References: <20170226151923.24669-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>,
        Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170226151923.24669-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/26/2017 09:19 AM, Colin King wrote:
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> trivial fix to spelling mistake in RT_TRACE message
>
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Bad fix. It should be althougth => through. Please read the context.

NACK.

Larry

> ---
>  drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
> index de98d88..dcb5d83 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
> @@ -812,7 +812,7 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
>  	 * pathA or mac1 has to set phy0&phy1 pathA */
>  	if ((content == radiob_txt) && (rfpath == RF90_PATH_A)) {
>  		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
> -			 " ===> althougth Path A, we load radiob.txt\n");
> +			 " ===> although Path A, we load radiob.txt\n");
>  		radioa_arraylen = radiob_arraylen;
>  		radioa_array_table = radiob_array_table;
>  	}
>
