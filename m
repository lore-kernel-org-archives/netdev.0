From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bonding: bond_get_size() returns wrong size
Date: Sat, 02 Nov 2013 02:09:33 -0400 (EDT)
Message-ID: <20131102.020933.1387162682618832151.davem@davemloft.net>
References: <20131101101844.GA29795@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	jiri@resnulli.us
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab3KBGJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 02:09:40 -0400
In-Reply-To: <20131101101844.GA29795@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 1 Nov 2013 13:18:44 +0300

> There is an extra semi-colon so bond_get_size() doesn't return the
> correct value.
> 
> Fixes: ec76aa49855f ('bonding: add Netlink support active_slave option')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks a lot Dan.
