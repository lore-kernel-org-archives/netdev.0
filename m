From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 2/2] netxen: firmware download improvements
Date: Tue, 03 Mar 2009 00:10:27 -0800 (PST)
Message-ID: <20090303.001027.229029533.davem@davemloft.net>
References: <1236045737-482-1-git-send-email-dhananjay@netxen.com>
	<1236045737-482-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbZCCIKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 03:10:45 -0500
In-Reply-To: <1236045737-482-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Mon,  2 Mar 2009 18:02:17 -0800

> o set port mode after resetting device.
> o prefer cut-through firmware (doesn't require on-card memory).
> o load flashed firmware if newer.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Also applied, thanks.
