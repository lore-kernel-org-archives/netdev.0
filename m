From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] VXLAN: Use tunnel_ip_select_ident() for
 tunnel IP-Identification.
Date: Mon, 25 Feb 2013 15:48:53 -0500 (EST)
Message-ID: <20130225.154853.635944788762772510.davem@davemloft.net>
References: <1361554240-1678-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402Ab3BYUsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:48:54 -0500
In-Reply-To: <1361554240-1678-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 22 Feb 2013 09:30:40 -0800

> tunnel_ip_select_ident() is more efficient when generating ip-header
> id given inner packet is of ipv4 type.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
