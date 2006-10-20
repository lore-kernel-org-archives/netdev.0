From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netpoll: initialize skb for UDP
Date: Thu, 19 Oct 2006 23:58:35 -0700 (PDT)
Message-ID: <20061019.235835.03111579.davem@davemloft.net>
References: <20061019171541.062261760@osdl.org>
	<20061019171814.026676621@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44182
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992522AbWJTG6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 02:58:33 -0400
To: shemminger@osdl.org
In-Reply-To: <20061019171814.026676621@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 19 Oct 2006 10:15:42 -0700

> Need to fully initialize skb to keep lower layers and queueing happy.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
