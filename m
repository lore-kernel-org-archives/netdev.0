From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] netpoll: inverted down_trylock() test
Date: Mon, 06 May 2013 11:08:30 -0400 (EDT)
Message-ID: <20130506.110830.1549027396957172067.davem@davemloft.net>
References: <20130506121513.GA13930@elgon.mountain>
	<20130506130024.GD4686@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, amwang@redhat.com, edumazet@google.com,
	jiri@resnulli.us, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607Ab3EFPId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 11:08:33 -0400
In-Reply-To: <20130506130024.GD4686@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 6 May 2013 16:00:24 +0300

> This is needed in mainline actually.  I typed -next by mistake.

Applied.
