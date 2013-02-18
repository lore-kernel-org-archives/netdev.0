From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip: fix warning in xfrm4_mode_tunnel_input
Date: Mon, 18 Feb 2013 12:43:16 -0500 (EST)
Message-ID: <20130218.124316.909314461716763522.davem@davemloft.net>
References: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
	<20130216094029.4d2fc993@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab3BRRnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:43:17 -0500
In-Reply-To: <20130216094029.4d2fc993@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 16 Feb 2013 09:40:29 -0800

> Same problem as IPv6
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
