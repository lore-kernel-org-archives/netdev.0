From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] remove an outdated reference to T/TCP
Date: Tue, 06 Dec 2011 15:19:20 -0500 (EST)
Message-ID: <20111206.151920.696192671128392379.davem@davemloft.net>
References: <20111206200005.836D529006DD@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab1LFUTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 15:19:42 -0500
In-Reply-To: <20111206200005.836D529006DD@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue,  6 Dec 2011 12:00:05 -0800 (PST)

> 
> Remove a particularly out of date bit of comment referring to T/TCP.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

I think it should stay because it discusses the potential bad side
effects of queueing any data that might be in the SYN.
