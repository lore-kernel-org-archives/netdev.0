From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix compilation with no IOV support
Date: Mon, 24 Jun 2013 01:48:04 -0700 (PDT)
Message-ID: <20130624.014804.1847359381186166068.davem@davemloft.net>
References: <1372061050-9206-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab3FXIsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:48:05 -0400
In-Reply-To: <1372061050-9206-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 24 Jun 2013 11:04:10 +0300

> This fixes an issue caused by submit 78c3bcc5d1af64f51d9f30b0f5a2d1985bf69734
> `bnx2x: Improve PF behaviour toward VF', which made the bnx2x driver fail
> compilation when PCI_IOV is not set.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
