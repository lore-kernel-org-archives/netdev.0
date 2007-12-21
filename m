From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9][BNX2]: Restructure IRQ datastructures.
Date: Thu, 20 Dec 2007 19:56:16 -0800 (PST)
Message-ID: <20071220.195616.250120238.davem@davemloft.net>
References: <1198182688.9163.28.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752433AbXLUD4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:56:17 -0500
In-Reply-To: <1198182688.9163.28.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:31:28 -0800

> [BNX2]: Restructure IRQ datastructures.
> 
> Add a table to keep track of multiple IRQs and restructure the IRQ
> request and free functions so that they can be easily expanded to
> handle multiple IRQs.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
