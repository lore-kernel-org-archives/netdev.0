From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix missing SCTP mailing list address
 update
Date: Sun, 19 Jan 2014 19:56:35 -0800 (PST)
Message-ID: <20140119.195635.870157965803222760.davem@davemloft.net>
References: <1390170293-15851-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dborkman@redhat.com
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbaATD4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:56:36 -0500
In-Reply-To: <1390170293-15851-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sun, 19 Jan 2014 15:24:53 -0700

> The commit 91705c61b5202 ("net: sctp: trivial: update mailing list
> address") updated almost all the SCTP mailing list address from
> 
> 	"lksctp-developers@lists.sourceforge.net"
> to
> 	"linux-sctp@vger.kernel.org"
> 
> except for the one in include/linux/sctp.h file. Fix this way trivial
> one so that all is updated.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied.
