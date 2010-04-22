From: David Miller <davem@davemloft.net>
Subject: Re: cxgb4: Make unnecessarily global functions static
Date: Wed, 21 Apr 2010 23:01:10 -0700 (PDT)
Message-ID: <20100421.230110.205394201.davem@davemloft.net>
References: <adapr1spr7e.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48606
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751333Ab0DVGBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:01:05 -0400
In-Reply-To: <adapr1spr7e.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 21 Apr 2010 11:59:17 -0700

> Also put t4_write_indirect() inside "#if 0" to avoid a "defined but not
> used" compile warning.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Also applied to net-next-2.6, thanks Roland.
