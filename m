From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] hso: Fix for endian issues on big endian machines
Date: Thu, 07 Jan 2010 00:44:08 -0800 (PST)
Message-ID: <20100107.004408.168595143.davem@davemloft.net>
References: <20100105145102.GB19825@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756033Ab0AGIoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:44:00 -0500
In-Reply-To: <20100105145102.GB19825@raptor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>
Date: Tue, 5 Jan 2010 15:51:02 +0100

> From: Jan Dumon <j.dumon@option.com>
> 
> Some fields are always little endian and have to be converted on big endian
> machines.
> 
> Signed-off-by: Jan Dumon <j.dumon@option.com>

Applied.
