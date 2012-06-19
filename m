From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 01/14] Add Default
Date: Tue, 19 Jun 2012 14:22:51 -0700 (PDT)
Message-ID: <20120619.142251.516617552797939214.davem@davemloft.net>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
	<1340118848-30978-2-git-send-email-yuvalmin@broadcom.com>
	<4FE0AABE.4070100@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab2FSVWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:22:52 -0400
In-Reply-To: <4FE0AABE.4070100@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 19 Jun 2012 09:37:18 -0700

> I'm not a big fan of just having this as a fixed define in the code.  It
> seems like it would make much more sense to have this in the Kconfig
> somewhere as a range value if you plan on making this changeable in the
> future.

Please not Kconfig :-/
