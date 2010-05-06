From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] netdev: octeon_mgmt: Try not to drop TX packets
 when stopping the queue.
Date: Thu, 06 May 2010 00:19:07 -0700 (PDT)
Message-ID: <20100506.001907.116374531.davem@davemloft.net>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
	<1273100593-11043-6-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754627Ab0EFHTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:19:00 -0400
In-Reply-To: <1273100593-11043-6-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed,  5 May 2010 16:03:12 -0700

> Stop the queue when we add the packet that will fill it instead of dropping the packet
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>

Applied.
