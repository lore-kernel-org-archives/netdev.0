From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipx: move peII functions
Date: Thu, 19 Jul 2012 10:49:50 -0700 (PDT)
Message-ID: <20120719.104950.569611284567111630.davem@davemloft.net>
References: <20120718120948.67611bdd@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab2GSRtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:49:51 -0400
In-Reply-To: <20120718120948.67611bdd@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Jul 2012 12:09:48 -0700

> The Ethernet II wrapper is only used by IPX protocol, may have once
> been used by Appletalk but not currently. Therefore it makes sense to 
> move it to the IPX dust bin and drop the exports.
> 
> Build tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
