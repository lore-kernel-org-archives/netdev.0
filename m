From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: make sctp_addr_wq_timeout_handler static
Date: Fri, 28 Dec 2012 20:33:03 -0800 (PST)
Message-ID: <20121228.203303.466763210063851049.davem@davemloft.net>
References: <20121228201855.4275db64@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab2L2EdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 23:33:07 -0500
In-Reply-To: <20121228201855.4275db64@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 28 Dec 2012 20:18:55 -0800

> Fix sparse warning about local function that should be static.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
