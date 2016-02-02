From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] e1000e: call ndo_stop() instead of
 dev_close() when running offline selftest
Date: Tue, 02 Feb 2016 16:28:30 -0500 (EST)
Message-ID: <20160202.162830.131864881309085395.davem@davemloft.net>
References: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
	<1454408028-16986-7-git-send-email-sassmann@kpanic.de>
	<56B0A843.9060703@kpanic.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: sassmann@kpanic.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbcBBV2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 16:28:33 -0500
In-Reply-To: <56B0A843.9060703@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Always, when sending an updated version of a patch which is part of a
series, always resubmit the entire series rather than just the patch
which is changing.

Thanks.
