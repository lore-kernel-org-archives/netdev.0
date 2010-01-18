From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2: Refine statistics code.
Date: Sun, 17 Jan 2010 19:16:22 -0800 (PST)
Message-ID: <20100117.191622.08620402.davem@davemloft.net>
References: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48119
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755237Ab0ARDQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:16:13 -0500
In-Reply-To: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 17 Jan 2010 09:30:43 -0800

> Refine the statistics macros by passing in just the name of the
> counter field.  This makes it a lot easier and cleaner to add
> counters saved before the last reset in the next patch.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
