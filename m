From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] CAN: Add missing Kbuild entries
Date: Thu, 27 Dec 2007 16:52:11 -0800 (PST)
Message-ID: <20071227.165211.63573287.davem@davemloft.net>
References: <477407BD.1040406@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752512AbXL1AwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 19:52:12 -0500
In-Reply-To: <477407BD.1040406@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 27 Dec 2007 21:14:53 +0100

> This patch adds the missing Kbuild entries and the missing Kbuild file 
> in include/linux/can for the CAN subsystem.
> 
> It applies on the current net-2.6.25 tree.
> 
> Tnx & best regards,
> Oliver
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Acked-by: Sam Ravnborg <sam@ravnborg.org>

Applied, but I had to fixup the patch to be rooted properly
like the other one.

Thanks.
