From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2x: Use pci_dev pm_cap
Date: Fri, 13 Sep 2013 20:13:45 -0400 (EDT)
Message-ID: <20130913.201345.524528457305699502.davem@davemloft.net>
References: <1378923760-16232-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827Ab3INANq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 20:13:46 -0400
In-Reply-To: <1378923760-16232-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Wed, 11 Sep 2013 11:22:39 -0700

> Use the already existing pm_cap variable in struct pci_dev for
> determining the power management offset.  This saves the driver from
> having to keep track of an extra variable.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
