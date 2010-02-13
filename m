From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] sky2 update for net-next
Date: Fri, 12 Feb 2010 16:21:40 -0800 (PST)
Message-ID: <20100212.162140.256632241.davem@davemloft.net>
References: <20100212165757.767062851@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613Ab0BMAV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 19:21:27 -0500
In-Reply-To: <20100212165757.767062851@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 12 Feb 2010 08:57:57 -0800

> Several little fixes:
>    * Change WoL setup to fix http://bugzilla.kernel.org/show_bug.cgi?id=13764
>    * Change Jumbo settings for some chips
>    * Mike's changes to avoid free and alloc on driver recovery

All applied to net-next-2.6, thanks!
