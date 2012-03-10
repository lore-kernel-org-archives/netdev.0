From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RE-SUBMIT] net/pch_gbe: supports eg20t ptp clock
Date: Sat, 10 Mar 2012 11:42:38 +0100
Message-ID: <20120310104238.GA3489@netboy.at.omicron.at>
References: <1331079669-22446-1-git-send-email-tshimizu818@gmail.com>
 <20120306.213453.700930266749202538.davem@davemloft.net>
 <20120309173032.GA5730@netboy.at.omicron.at>
 <20120309.130006.1423350346805366510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tshimizu818@gmail.com, jeffrey.t.kirsher@intel.com,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, arnd@arndb.de, khc@pm.waw.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63691 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232Ab2CJKmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 05:42:47 -0500
Content-Disposition: inline
In-Reply-To: <20120309.130006.1423350346805366510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 09, 2012 at 01:00:06PM -0800, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Fri, 9 Mar 2012 18:30:32 +0100
> 
> > On Tue, Mar 06, 2012 at 09:34:53PM -0500, David Miller wrote:
> >> 
> >> You still haven't submitted this properly.
> >> 
> >> First, you submitted the PCH_GBE driver changes before the EG20T
> >> PTP clock driver which it depends upon.
> > 
> > David, both this pair of patches and the second pair apply cleanly to
> > both Torvalds mainline and to net-next. So, what are you complaining
> > about here? I am still confused.
> 
> I'm complaining submitting changes properly, and that has nothing
> to do with where or how cleanly the patches apply.

After reviewing the patches, now I see the dependencies.

Sorry for the noise,

Richard
