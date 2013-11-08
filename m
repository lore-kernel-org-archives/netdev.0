From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 0/2] l2 hardware accelerated macvlans
Date: Thu, 07 Nov 2013 19:12:44 -0500 (EST)
Message-ID: <20131107.191244.1462002095786588675.davem@davemloft.net>
References: <20131106175308.3822.73239.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, alexander.h.duyck@intel.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab3KHAMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:12:46 -0500
In-Reply-To: <20131106175308.3822.73239.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Wed, 06 Nov 2013 09:54:40 -0800

> This patch adds support to offload macvlan net_devices to the
> hardware. With these patches packets are pushed to the macvlan
> net_device directly and do not pass through the lower dev.

Series applied, looks great.

Thanks.
