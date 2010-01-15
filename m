From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethoc: Use resource_size
Date: Fri, 15 Jan 2010 01:48:37 -0800 (PST)
Message-ID: <20100115.014837.112516712.davem@davemloft.net>
References: <1263487568-13682-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755188Ab0AOJs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 04:48:28 -0500
In-Reply-To: <1263487568-13682-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 14 Jan 2010 17:46:08 +0100

> Use the resource_size function instead of manually calculating the
> resource size.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next-2.6, thanks.
