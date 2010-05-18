From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] X25: Move qbit flag to bitfield
Date: Mon, 17 May 2010 17:39:37 -0700 (PDT)
Message-ID: <20100517.173937.200358463.davem@davemloft.net>
References: <1274086781.4104.52.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752542Ab0ERAj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:39:28 -0400
In-Reply-To: <1274086781.4104.52.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Mon, 17 May 2010 18:59:41 +1000

> Moves the X25 q bit flag from char into a bitfield to allow BKL cleanup.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
