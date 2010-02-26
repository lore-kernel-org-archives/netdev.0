From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] octeon: convert to use
 netdev_for_each_mc_addr
Date: Fri, 26 Feb 2010 01:50:02 -0800 (PST)
Message-ID: <20100226.015002.211083574.davem@davemloft.net>
References: <20100223195457.GF2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935611Ab0BZJto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:49:44 -0500
In-Reply-To: <20100223195457.GF2673@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 23 Feb 2010 20:54:58 +0100

> Hmm so actually my original patch including this bit was correct,
> "list = list->next;" confused me :) - will send patch correcting that in a few.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
