From: David Miller <davem@davemloft.net>
Subject: Re: [v2, 0/3] Add PTP support for ls1021a platform
Date: Thu, 25 Feb 2016 16:22:23 -0500 (EST)
Message-ID: <20160225.162223.1178855468165388993.davem@davemloft.net>
References: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, afleming@gmail.com,
	galak@codeaurora.org, claudiu.manoil@freescale.com,
	richardcochran@gmail.com
To: yangbo.lu@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbcBYVW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:22:26 -0500
In-Reply-To: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yangbo Lu <yangbo.lu@nxp.com>
Date: Wed, 24 Feb 2016 17:26:53 +0800

> This patchset is to enable ptp support for ls1021a platform. The endianness
> issue in gianfar driver and gianfar ptp driver must be fixed, and a 1588
> timer node must be added into dts.
> 
> Changes for v2:
> 	- Modified commit message
> 	- Added more reviewers

Series applied to net-next, thanks.
