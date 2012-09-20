From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2012-09-19
Date: Thu, 20 Sep 2012 16:42:43 -0400 (EDT)
Message-ID: <20120920.164243.1102617524689876120.davem@davemloft.net>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, giometti@enneenne.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	ajackson@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab2ITUmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 16:42:49 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Sep 2012 20:09:35 +0100

> The following changes since commit b4516a288e71c64d7e214902250baf78b7b3cdcf:
> 
>   llc: Remove stray reference to sysctl_llc_station_ack_timeout. (2012-09-17 13:13:24 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit 450783747f42dfa3883920acfad4acdd93ce69af)
> 
> 1. Extension to PPS/PTP to allow for PHC devices where pulses are
>    subject to a variable but measurable delay.
> 2. PPS/PTP/PHC support for Solarflare boards with a timestamping 
>    peripheral.
> 3. MTD support for updating the timestamping peripheral on those boards.
> 4. Fix for potential over-length requests to firmware.

Pulled, thanks Ben.
