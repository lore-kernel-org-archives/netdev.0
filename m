From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH][V2] rtlwifi: rtl8192de: ix spelling mistake: "althougth" -> "though"
Date: Tue, 07 Mar 2017 16:24:28 +0200
Message-ID: <87wpc188rn.fsf@kamboji.qca.qualcomm.com>
References: <20170226185246.28808-1-colin.king@canonical.com>
        <9ddfcfdc-42c6-e302-e12b-1f9660f20ad4@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Colin King <colin.king@canonical.com>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Arnd Bergmann <arnd@arndb.de>,
        Oleg Drokin <green@linuxhacker.ru>,
        Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43404 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755874AbdCGPWh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 10:22:37 -0500
In-Reply-To: <9ddfcfdc-42c6-e302-e12b-1f9660f20ad4@lwfinger.net> (Larry
        Finger's message of "Sun, 26 Feb 2017 13:01:31 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 02/26/2017 12:52 PM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> trivial fix to spelling mistake in RT_TRACE message
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
>
> Thanks,
>
> Larry
>
>>
>> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
>> index de98d88..dcb5d83 100644
>> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
>> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/phy.c
>> @@ -812,7 +812,7 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
>>  	 * pathA or mac1 has to set phy0&phy1 pathA */
>>  	if ((content == radiob_txt) && (rfpath == RF90_PATH_A)) {
>>  		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
>> -			 " ===> althougth Path A, we load radiob.txt\n");
>> +			 " ===> though Path A, we load radiob.txt\n");

Wasn't this supposed to be "through"? Or did I miss something?

-- 
Kalle Valo
