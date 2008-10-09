From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] bnx2: Update 5706/5708 firmware.
Date: Thu, 09 Oct 2008 12:23:03 -0700 (PDT)
Message-ID: <20081009.122303.96631109.davem@davemloft.net>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
	<1223572568-1298-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760902AbYJITX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:23:27 -0400
In-Reply-To: <1223572568-1298-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu,  9 Oct 2008 10:16:05 -0700

> With this new firmware, the driver no longer has to modify the
> TCP/IP header fields when transmitting TSO packets.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
