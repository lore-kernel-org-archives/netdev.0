From: David Miller <davem@davemloft.net>
Subject: Re: [net] ptp: update adjfreq callback description
Date: Sat, 03 Nov 2012 15:27:41 -0400 (EDT)
Message-ID: <20121103.152741.556998528464634188.davem@davemloft.net>
References: <1351809016-29237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org,
	richard.cochran@gmail.com, john.stultz@linaro.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829Ab2KCT1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:27:43 -0400
In-Reply-To: <1351809016-29237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  1 Nov 2012 15:30:16 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch updates the adjfreq callback description to include a note that the
> delta in ppb is always relative to the base frequency, and not to the current
> frequency of the hardware clock.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> CC: stable@vger.kernel.org [v3.5+]
> CC: Richard Cochran <richard.cochran@gmail.com>
> CC: John Stultz <john.stultz@linaro.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
