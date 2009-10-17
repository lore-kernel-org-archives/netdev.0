From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/7] netxen; update version to 4.0.56
Date: Fri, 16 Oct 2009 17:56:21 -0700 (PDT)
Message-ID: <20091016.175621.76312736.davem@davemloft.net>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
	<1255673353-31797-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53024
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752359AbZJQAz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 20:55:59 -0400
In-Reply-To: <1255673353-31797-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu, 15 Oct 2009 23:09:07 -0700

> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

This doesn't make any sense at all.

You should update the driver version _AFTER_ your set
of changes, not before.

I have never in my entire life seen someone bump the
driver version before the actual changes.

Please respin this properly, thanks.
