From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RE-SUBMIT] net/pch_gbe: supports eg20t ptp clock
Date: Fri, 09 Mar 2012 13:00:06 -0800 (PST)
Message-ID: <20120309.130006.1423350346805366510.davem@davemloft.net>
References: <1331079669-22446-1-git-send-email-tshimizu818@gmail.com>
	<20120306.213453.700930266749202538.davem@davemloft.net>
	<20120309173032.GA5730@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tshimizu818@gmail.com, jeffrey.t.kirsher@intel.com,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, arnd@arndb.de, khc@pm.waw.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120309173032.GA5730@netboy.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 9 Mar 2012 18:30:32 +0100

> On Tue, Mar 06, 2012 at 09:34:53PM -0500, David Miller wrote:
>> 
>> You still haven't submitted this properly.
>> 
>> First, you submitted the PCH_GBE driver changes before the EG20T
>> PTP clock driver which it depends upon.
> 
> David, both this pair of patches and the second pair apply cleanly to
> both Torvalds mainline and to net-next. So, what are you complaining
> about here? I am still confused.

I'm complaining submitting changes properly, and that has nothing
to do with where or how cleanly the patches apply.
