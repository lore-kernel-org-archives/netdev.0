From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] myri10ge: Mask PCI Surprise Link Down Events
Date: Wed, 29 Jun 2011 06:02:39 -0700 (PDT)
Message-ID: <20110629.060239.1429964518681093544.davem@davemloft.net>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-2-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab1F2NCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:02:41 -0400
In-Reply-To: <1309187108-12715-2-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <mason@myri.com>
Date: Mon, 27 Jun 2011 10:05:01 -0500

> A SRAM parity error can cause a surprise link down.  Since We can
> recover from SRAM parity errors, mask PCI surprise down events.
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Applied.
