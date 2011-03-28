From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix LRO disable warning
Date: Sun, 27 Mar 2011 23:29:13 -0700 (PDT)
Message-ID: <20110327.232913.241918382.davem@davemloft.net>
References: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
	<20110327.180818.39174806.davem@davemloft.net>
	<99737F4847ED0A48AECC9F4A1974A4B80FD10E8849@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, rajesh.borundia@qlogic.com,
	sgruszka@redhat.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46165
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752005Ab1C1G3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 02:29:51 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8849@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Salecha <amit.salecha@qlogic.com>
Date: Mon, 28 Mar 2011 00:33:43 -0500

> I thought you will apply patch from Stanislaw Gruszka (net: fix
> ethtool->set_flags not intended -EINVAL return value), which is more
> generic and takes care of all drivers.
> 
> David, you are not cc in that patch. I will forward you, in case you miss it.

Ok, I was wondering about that, thanks for explaining I'll fix this up.
