From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 01/12] sky2: support ethtool set_phys_id
Date: Wed, 06 Apr 2011 14:30:35 -0700 (PDT)
Message-ID: <20110406.143035.191389005.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184501.356412753@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53167
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932162Ab1DFVbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:31:12 -0400
In-Reply-To: <20110404184501.356412753@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 11:43:41 -0700

> Use ethtool set_phys_id to control LED. Fixes issues with RTNL being
> held for extended periods.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
