From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851: suspend resume support
Date: Mon, 08 Nov 2010 13:43:18 -0800 (PST)
Message-ID: <20101108.134318.245393709.davem@davemloft.net>
References: <27F9C60D11D683428E133F85D2BB4A530468882D59@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: x0066660@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755528Ab0KHVmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:42:54 -0500
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A530468882D59@dlee03.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Arce, Abraham" <x0066660@ti.com>
Date: Thu, 28 Oct 2010 23:57:20 -0500

> Add suspend/resume support using default open/stop interface methods
> to do hardware dependant operations.
> 
> On suspend, same low power state (soft power mode) will be kept, the
> following blocks will be disabled:
> 
>  - Internal PLL Clock
>  - Tx/Rx PHY
>  - MAC
>  - SPI Interface
> 
> Signed-off-by: Abraham Arce <x0066660@ti.com>

Applied.
