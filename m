From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 02/12] netxen: enable ip addr hashing
Date: Mon, 27 Jul 2009 10:33:39 -0700 (PDT)
Message-ID: <20090727.103339.18263935.davem@davemloft.net>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit@netxen.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753273AbZG0Rdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 13:33:33 -0400
In-Reply-To: <1248674867-18821-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 26 Jul 2009 23:07:37 -0700

> NX3031 hardware requires local IP addresses for packet
> accumulation (LRO). IP address hashing is required to
> distinguish a local TCP flow from others (forwarded or
> guest).
> 
> This patch adds listener for IP and netdev events and
> configures IP address in the firmware.
> 
> Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
