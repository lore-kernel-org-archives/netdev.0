From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] be2net: Maintain tx and rx counters in driver
Date: Fri, 19 Feb 2010 17:12:07 -0800 (PST)
Message-ID: <20100219.171207.203287738.davem@davemloft.net>
References: <20100219235702.GA12931@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753358Ab0BTBLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 20:11:50 -0500
In-Reply-To: <20100219235702.GA12931@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Sat, 20 Feb 2010 05:27:12 +0530

> For certain skews of the BE adapter, H/W Tx and Rx
> counters could be common for more than one interface.
> Add Tx and Rx counters in the adapter structure
> (to maintain stats on a per interfae basis).
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
