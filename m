From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] skge: don't assert carrier until link is up
Date: Sun, 22 Jan 2012 14:24:23 -0500 (EST)
Message-ID: <20120122.142423.250841291801904665.davem@davemloft.net>
References: <20120119163525.764252ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab2AVTY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:24:26 -0500
In-Reply-To: <20120119163525.764252ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Jan 2012 16:35:25 -0800

> Skge device would assert carrier (link up) as soon as network device open
> was called, rather than waiting until PHY has detected link.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
