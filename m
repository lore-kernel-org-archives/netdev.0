From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/22] Subject qlge: fix sparse warnings
Date: Fri, 21 Nov 2008 17:29:55 -0800 (PST)
Message-ID: <20081121.172955.16927502.davem@davemloft.net>
References: <20081121232138.343333942@vyatta.com>
	<20081121232239.233383973@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753653AbYKVB34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:29:56 -0500
In-Reply-To: <20081121232239.233383973@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Nov 2008 15:21:42 -0800

> Fix sparse warnings and one bug:
>     * Several routines can be static
>     * Don't lose __iomem annotation
>     * fix locking on error path (bug)
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
