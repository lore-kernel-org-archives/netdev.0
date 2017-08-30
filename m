From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: btcoex: 23b 1ant: fix duplicated code for
 different branches
Date: Wed, 30 Aug 2017 11:37:06 -0500
Message-ID: <eef42b52-ae7b-e574-237f-209ac8ec033c@lwfinger.net>
References: <20170830134223.GA13596@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Pkshih <pkshih@realtek.com>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830134223.GA13596@embeddedgus>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 08:42 AM, Gustavo A. R. Silva wrote:
> Refactor code in order to avoid identical code for different branches.
> 
> This issue was detected with the help of Coccinelle.
> 
> Addresses-Coverity-ID: 1226788
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
> This issue was reported by Coverity and it was tested by compilation only.
> I'm suspicious this may be a copy/paste error. Please, verify.

I have referred this change to the engineers at Realtek. For the moment, please 
hold this patch.

Thanks for reporting the condition.

Larry
