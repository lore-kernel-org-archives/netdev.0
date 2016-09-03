From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1,v2] rtlwifi: remove superfluous condition
Date: Sat,  3 Sep 2016 10:03:33 +0000 (UTC)
Message-ID: <20160903100333.1536E6201B@smtp.codeaurora.org>
References: <1470165981-6241-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470165981-6241-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> If sta == NULL, the changed line will not be reached.
> So no need to check that sta != NULL here.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, 1 patch applied to wireless-drivers-next.git:

f898005ff99f rtlwifi: remove superfluous condition

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9260253/
