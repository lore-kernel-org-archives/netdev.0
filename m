From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/7] Fixing the "Time Counter fixes and
 improvements"
Date: Fri, 02 Jan 2015 16:48:12 -0500 (EST)
Message-ID: <20150102.164812.816408120629892371.davem@davemloft.net>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
	<cover.1420226266.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.stultz@linaro.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbABVsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:48:15 -0500
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri,  2 Jan 2015 20:22:02 +0100

> For this series I had only tested the build with ARCH=x86 and arm, but
> others like sparc64, microblaze, powerpc, and s390 will fail because
> they somehow don't indirectly include clocksource.h for the drivers in
> question.
> 
> This series fixes the build issues reported by:
>  kbuild test robot <fengguang.wu@intel.com>

Series applied, thanks Richard.
