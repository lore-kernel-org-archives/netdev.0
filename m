From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] hso: don't change the state of a closed port
Date: Thu, 07 Jan 2010 00:44:15 -0800 (PST)
Message-ID: <20100107.004415.257372275.davem@davemloft.net>
References: <20100105145127.GC19825@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756006Ab0AGIoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:44:07 -0500
In-Reply-To: <20100105145127.GC19825@raptor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>
Date: Tue, 5 Jan 2010 15:51:28 +0100

> From: Jan Dumon <j.dumon@option.com>
> 
> Don't change the state of a port if it's not open. This fixes an issue where a
> port sometimes has to be opened twice before data can be received.
> 
> Signed-off-by: Jan Dumon <j.dumon@option.com>

Applied.
