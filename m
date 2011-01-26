From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cnic: Fix big endian bug
Date: Wed, 26 Jan 2011 14:26:29 -0800 (PST)
Message-ID: <20110126.142629.39195972.davem@davemloft.net>
References: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754335Ab1AZWZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 17:25:55 -0500
In-Reply-To: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 26 Jan 2011 00:14:50 -0800

> The chip's page tables did not set up properly on big endian machines,
> causing EEH errors on PPC machines.
> 
> Reported-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
