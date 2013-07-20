From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Sat, 20 Jul 2013 12:20:58 -0700 (PDT)
Message-ID: <20130720.122058.1139915094969451326.davem@davemloft.net>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab3GTTU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 15:20:59 -0400
In-Reply-To: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 20 Jul 2013 10:26:57 -0700

> +	unsigned i;

Please use an explicit "unsigned int", thank you.
