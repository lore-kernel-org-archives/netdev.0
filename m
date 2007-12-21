From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] tg3: Separate requested and actual flow control
 parameters
Date: Thu, 20 Dec 2007 20:05:53 -0800 (PST)
Message-ID: <20071220.200553.257982593.davem@davemloft.net>
References: <1198191589.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbXLUEFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:05:53 -0500
In-Reply-To: <1198191589.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 14:59:49 -0800

> This patch removes the TX and RX flow control flags from tg3_flags and
> adds two new flow control variables, flowctrl and active_flowctrl.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
