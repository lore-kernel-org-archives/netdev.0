From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RE-SUBMIT 1/2] supports eg20t ptp clock
Date: Fri, 09 Mar 2012 13:56:24 -0800 (PST)
Message-ID: <20120309.135624.1280331660653754919.davem@davemloft.net>
References: <1331194587-29114-1-git-send-email-tshimizu818@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, lucas.demarchi@profusion.mobi,
	mirq-linux@rere.qmqm.pl, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, john.stultz@linaro.org, richardcochran@gmail.com,
	arnd@arndb.de, khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, joel.clark@intel.com, kok.howg.ewe@intel.com
To: tshimizu818@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331194587-29114-1-git-send-email-tshimizu818@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Takahiro Shimizu <tshimizu818@gmail.com>
Date: Thu,  8 Mar 2012 17:16:26 +0900

> Supports EG20T ptp clock in the driver
> 
> Changes e-mail address.
> 
> Adds number.
> 
> Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>

Applied, but I had to fix trailing empty lines you added to a file:

> +++ b/drivers/ptp/ptp_pch.c
> @@ -0,0 +1,731 @@
 ...
> +MODULE_DESCRIPTION("PTP clock using the EG20T timer");
> +MODULE_LICENSE("GPL");
> +

There.
