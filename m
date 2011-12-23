From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usb: pegasus: cleanup a couple conditions
Date: Fri, 23 Dec 2011 16:52:32 -0500 (EST)
Message-ID: <20111223.165232.1727326086882956386.davem@davemloft.net>
References: <20111223104436.GA8592@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@users.sourceforge.net, gregkh@suse.de,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab1LWVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 16:52:50 -0500
In-Reply-To: <20111223104436.GA8592@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 23 Dec 2011 13:44:36 +0300

> We recently made loopback a bool type instead of an int, so the bitwise
> AND is redundent.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
