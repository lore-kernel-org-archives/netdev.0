From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: remove pcie workaround
Date: Thu, 12 Feb 2009 16:41:22 -0800 (PST)
Message-ID: <20090212.164122.157552011.davem@davemloft.net>
References: <1234380573-16903-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758098AbZBMAl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:41:28 -0500
In-Reply-To: <1234380573-16903-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed, 11 Feb 2009 11:29:33 -0800

> Remove workaround for pcie bug in early revisions of NX3031
> (rev 41 or earlier). This is taken care of during firmware init.
> 
> The workaround required writing pcie config reg of every
> pcie function on a card, not all of which are enabled.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
