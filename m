From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] tg3: Prevent corruption at 10 / 100Mbps w CLKREQ
Date: Fri, 21 Nov 2008 17:18:28 -0800 (PST)
Message-ID: <20081121.171828.202736628.davem@davemloft.net>
References: <1227295575.5616@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753842AbYKVBS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:18:29 -0500
In-Reply-To: <1227295575.5616@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:00:42 -0800

> This patch disables CLKREQ at 10Mbps and 100Mbps to workaround a TX BD
> corruption issue.  This problem only affects the 5784 and 5761 (and
> 57780 AX) ASIC revisions.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
