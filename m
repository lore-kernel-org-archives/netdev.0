From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bnx2x: enhancement patch series
Date: Mon, 27 May 2013 21:42:07 -0700 (PDT)
Message-ID: <20130527.214207.2008439041026381097.davem@davemloft.net>
References: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab3E1EmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 00:42:10 -0400
In-Reply-To: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 27 May 2013 17:08:25 +0300

> This series contains several enhancements, mainly the implementation of the
> PCI shutdown callback which improves the bnx2x support in un-orderly shutdowns,
> and following that a change in the driver's power scheme which lowers PCI power
> state only when driver is removed (and as a result enable eeprom access on
> unloaded interfaces).
> 
> Please consider applying these patches to `net-next'.

Series applied, thanks.
