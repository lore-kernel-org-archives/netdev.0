From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas_tf: Drop unused variable and define
Date: Thu, 16 Jun 2016 15:14:31 +0000 (UTC)
Message-ID: <20160616151431.5429461372@smtp.codeaurora.org>
References: <1464986935-23361-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464986935-23361-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guenter Roeck <linux@roeck-us.net> wrote:
> gcc-6 reports:
> 
> drivers/net/wireless/marvell/libertas_tf/main.c:30:19: error:
> 	'lbtf_driver_version' defined but not used
> 
> with -Werror=unused-const-variable=.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Thanks, 1 patch applied to wireless-drivers-next.git:

035ddbc59f54 libertas_tf: Drop unused variable and define

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9154015/
