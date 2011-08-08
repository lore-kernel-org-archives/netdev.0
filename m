From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 NEXT 1/1] netxen: add vlan LRO support
Date: Sun, 07 Aug 2011 22:53:44 -0700 (PDT)
Message-ID: <20110807.225344.2052172031549537207.davem@davemloft.net>
References: <1312685204-19800-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab1HHFxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:53:48 -0400
In-Reply-To: <1312685204-19800-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <amit.salecha@qlogic.com>
Date: Sat, 6 Aug 2011 19:46:44 -0700

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> o To support vlan lro, driver need to program ip address in device.
> o Same ip addresses need to be program after fw recovery, so sotre them
>   in list.
> o In case of vlan packet, include vlan header length while
> calculating ip and tcp headers.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
