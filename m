From: David Miller <davem@davemloft.net>
Subject: Re: [BRIDGE]: Fix fdb RCU race
Date: Thu, 22 Mar 2007 12:25:41 -0700 (PDT)
Message-ID: <20070322.122541.21915693.davem@davemloft.net>
References: <4602CAF5.609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933983AbXCVTZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:25:41 -0400
In-Reply-To: <4602CAF5.609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 22 Mar 2007 19:29:09 +0100

> Fix what looks like a RCU race. Untested since this is only
> used by ATM, which I don't have.

Also applied, thanks Patrick.

