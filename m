From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 18:40:32 -0500 (EST)
Message-ID: <20111116.184032.1176336205445892405.davem@davemloft.net>
References: <1321486057-30968-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab1KPXke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 18:40:34 -0500
In-Reply-To: <1321486057-30968-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 16 Nov 2011 15:27:37 -0800

> Translating between ethtool advertisement settings and MII
> advertisements are common operations for ethernet drivers.  This patch
> adds a set of helper functions that implements the conversion.  The
> patch then modifies a couple of the drivers to use the new functions.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks better, applied, thanks :)
