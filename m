From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] VXLAN: segmentation offload
Date: Sat, 09 Mar 2013 16:11:12 -0500 (EST)
Message-ID: <20130309.161112.329901412822645133.davem@davemloft.net>
References: <1362698490-2378-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3CIVLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 16:11:07 -0500
In-Reply-To: <1362698490-2378-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu,  7 Mar 2013 15:21:30 -0800

> Following patches add segmentation offload to VXLAN. These
> patches shows performance improvement from 3.9G to 5.8G (+50%)
> with netperf single process TCP_STREAM test on 10G network.

Series applied.
