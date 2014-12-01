From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] openvswitch: Fix flow mask validation.
Date: Mon, 1 Dec 2014 09:42:44 +0000
Message-ID: <20141201094244.GA619@casper.infradead.org>
References: <1417417457-1492-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57296 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbaLAJms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 04:42:48 -0500
Content-Disposition: inline
In-Reply-To: <1417417457-1492-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/14 at 11:04pm, Pravin B Shelar wrote:
> Following patch fixes typo in the flow validation. This prevented
> installation of ARP and IPv6 flows.
> 
> Fixes: 19e7a3df72 ("openvswitch: Fix NDP flow mask validation")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Thomas Graf <tgraf@suug.ch>
