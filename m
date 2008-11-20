From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: remove hardcoded sram_size
Date: Thu, 20 Nov 2008 01:50:38 -0800 (PST)
Message-ID: <20081120.015038.101210231.davem@davemloft.net>
References: <49232163.9050902@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753577AbYKTJui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:50:38 -0500
In-Reply-To: <49232163.9050902@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Tue, 18 Nov 2008 21:11:15 +0100

> Removes the use of a hardcoded sram_size, determine string_spec
> location from the MCP header instead.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Also applied, thanks Brice.
