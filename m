From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] phylib: Add interrupt source check function to
 M88E1121R driver
Date: Mon, 13 Apr 2009 14:51:50 -0700 (PDT)
Message-ID: <20090413.145150.208370427.davem@davemloft.net>
References: <1239105703-26240-1-git-send-email-agust@denx.de>
	<1239105703-26240-2-git-send-email-agust@denx.de>
	<1239105703-26240-3-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751421AbZDMVv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:51:59 -0400
In-Reply-To: <1239105703-26240-3-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Tue,  7 Apr 2009 14:01:43 +0200

> Add did_interrupt() function to check if a PHY port
> really caused an interrupt. This is needed in the case
> of shared PHY interrupt pin configuration to stop
> interrupt event processing for PHY ports which didn't
> cause an interrupt.
> 
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied.
