From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] ewrk3: convert to set_phys_id
Date: Wed, 06 Apr 2011 15:06:06 -0700 (PDT)
Message-ID: <20110406.150606.90808028.davem@davemloft.net>
References: <20110404210805.998401718@linuxplumber.net>
	<20110406.143720.55846981.davem@davemloft.net>
	<20110406145836.35af537a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756787Ab1DFWGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 18:06:43 -0400
In-Reply-To: <20110406145836.35af537a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 6 Apr 2011 14:58:36 -0700

> Use ethtool infrastructure for blinking, which is now does
> locking at higher level.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
