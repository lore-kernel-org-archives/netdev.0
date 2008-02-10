From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] Replace using the magic constant "1024" with
 IP6_RT_PRIO_USER for fc_metric.
Date: Sat, 09 Feb 2008 23:43:27 -0800 (PST)
Message-ID: <20080209.234327.183096436.davem@davemloft.net>
References: <eb3ff54b0802080214u5c20f061of4144964c8776359@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756065AbYBJHmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:42:55 -0500
In-Reply-To: <eb3ff54b0802080214u5c20f061of4144964c8776359@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Fri, 8 Feb 2008 12:14:18 +0200

>   This patch replaces the explicit usage of the magic constant "1024"
> with IP6_RT_PRIO_USER in the IPV6 tree.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
