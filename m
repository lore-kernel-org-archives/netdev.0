From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/atl1c/atl1c_main.c: use %pM to show MAC
 address
Date: Thu, 07 Jan 2010 01:18:37 -0800 (PST)
Message-ID: <20100107.011837.129472809.davem@davemloft.net>
References: <201001050954.01826.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932904Ab0AGJS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:18:28 -0500
In-Reply-To: <201001050954.01826.hartleys@visionengravers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 09:54:01 -0700

> Use the %pM kernel extension to display the MAC address.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
