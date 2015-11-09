From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: Documentation: Fix default value
 tcp_limit_output_bytes
Date: Mon, 09 Nov 2015 12:17:51 -0500 (EST)
Message-ID: <20151109.121751.1553624859438610838.davem@davemloft.net>
References: <1447081140-16955-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, niklass@axis.com
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbbKIRRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 12:17:53 -0500
In-Reply-To: <1447081140-16955-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 9 Nov 2015 15:59:00 +0100

> Commit c39c4c6abb89 ("tcp: double default TSQ output bytes limit")
> updated default value for tcp_limit_output_bytes
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, thanks.
