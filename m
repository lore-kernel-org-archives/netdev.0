From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (v2) 0/6] bnx2x: link patch series
Date: Fri, 22 Jun 2012 17:20:54 -0700 (PDT)
Message-ID: <20120622.172054.1832176727496878280.davem@davemloft.net>
References: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, joe@perches.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597Ab2FWAUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:20:55 -0400
In-Reply-To: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 21 Jun 2012 08:05:17 +0300

> Hi Dave,
> 
> This patch series change bnx2x's link code. It contains both
> semantic cleanup of the code as well as several patches that
> add new support for optical modules - better 1G SFP support,
> SFP+ Tx Fault support and implementation of the new ethtool API
> for accessing the module's eeprom (on the bnx2x side).
> 
> Changes from Version 1:
>   - Patch 2/6 - use usleep_range(small, small*2) instead of
> 		usleep_range(small, small).
> 
> 
> Please consider applying this patch-series to 'net-next'.

All applied, thanks.
