From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 14:33:49 -0400 (EDT)
Message-ID: <20110614.143349.1778665510231099747.davem@davemloft.net>
References: <1308072953.9492.4.camel@HP1>
	<20110614.134653.607599293786464713.davem@davemloft.net>
	<35D366A0-235E-44ED-8D5B-AEDB1D8AC0F5@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, bprakash@broadcom.com, eilong@broadcom.com,
	netdev@vger.kernel.org, dmitry@broadcom.com,
	yaniv.rosner@broadcom.com, dwmw2@infradead.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1FNSfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 14:35:00 -0400
In-Reply-To: <35D366A0-235E-44ED-8D5B-AEDB1D8AC0F5@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Tue, 14 Jun 2011 11:32:04 -0700

> This requires some sync between Dave and David: David should always
> be the first to integrate a new FW and only then Dave should
> inegrate a driver patch series with the support for this new FW. The
> responsibility for the ordering should be on the driver owner: in
> our case, i shouldn't be sending a net-next patch series until the
> linux-firmware patch is applied.

Ok, then let's get this propagated into David's firmware tree.
