From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: avoid null pointer dereference when
 enabling SR-IOV
Date: Thu, 05 Dec 2013 20:57:24 -0500 (EST)
Message-ID: <20131205.205724.1929205757758233437.davem@davemloft.net>
References: <1386151494-28876-1-git-send-email-michals@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: michals@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3LFB50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:57:26 -0500
In-Reply-To: <1386151494-28876-1-git-send-email-michals@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <michals@broadcom.com>
Date: Wed, 4 Dec 2013 12:04:54 +0200

> Fixed NULL pointer dereference when dynamically activating SR-IOV after vf
> database failed to be allocated in probe stage (for example due to no ARI
> support in pci hub).
> 
> Signed-off-by: Michal Kalderon <michals@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
