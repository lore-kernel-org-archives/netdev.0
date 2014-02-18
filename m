From: David Miller <davem@davemloft.net>
Subject: Re: [patch] af_packet: remove a stray tab in packet_set_ring()
Date: Tue, 18 Feb 2014 18:02:55 -0500 (EST)
Message-ID: <20140218.180255.128347172273175403.davem@davemloft.net>
References: <20140218122050.GB9604@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, edumazet@google.com, phil@nwl.cc,
	atzm@stratosphere.co.jp, richardcochran@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaBRXC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:02:59 -0500
In-Reply-To: <20140218122050.GB9604@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 18 Feb 2014 15:20:51 +0300

> At first glance it looks like there is a missing curly brace but
> actually the code works the same either way.  I have adjusted the
> indenting but left the code the same.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thank you.
