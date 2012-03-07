From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RE-SUBMIT] net/pch_gbe: supports eg20t ptp clock
Date: Tue, 06 Mar 2012 21:34:53 -0500 (EST)
Message-ID: <20120306.213453.700930266749202538.davem@davemloft.net>
References: <1331079669-22446-1-git-send-email-tshimizu818@gmail.com>
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
In-Reply-To: <1331079669-22446-1-git-send-email-tshimizu818@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You still haven't submitted this properly.

First, you submitted the PCH_GBE driver changes before the EG20T
PTP clock driver which it depends upon.

Second, you didn't number your patches.  When you submit a patch
series you must number them so that there is no confusion about
what order those patches should be applied.
