From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2: Always set ETH_FLAG_TXVLAN
Date: Mon, 24 Jan 2011 23:16:31 -0800 (PST)
Message-ID: <20110124.231631.104075024.davem@davemloft.net>
References: <1295909942-758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jesse@nicira.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42405
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751517Ab1AYHP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:15:57 -0500
In-Reply-To: <1295909942-758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 24 Jan 2011 14:59:02 -0800

> TSO does not work if the VLAN tag is in the packet (non-accelerated).
> We may be able to remove this restriction in future firmware.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
