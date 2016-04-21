From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/3] qede: Bug fixes
Date: Thu, 21 Apr 2016 14:51:52 -0400 (EDT)
Message-ID: <20160421.145152.1580125484272512234.davem@davemloft.net>
References: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbcDUSvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:51:54 -0400
In-Reply-To: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Wed, 20 Apr 2016 03:03:26 -0400

> This series fixes -
> 
> * various memory allocation failure flows for fastpath
> * issues with respect to driver GRO packets handling
> 
> V1->V2
> 
> * Send series against net instead of net-next.
> 
> Please consider applying this series to "net"

Series applied, thanks.
