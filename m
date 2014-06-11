From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] mlx4 SRIOV fixes
Date: Wed, 11 Jun 2014 00:33:27 -0700 (PDT)
Message-ID: <20140611.003327.2058600077859953054.davem@davemloft.net>
References: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbaFKHd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:33:28 -0400
In-Reply-To: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  8 Jun 2014 13:49:44 +0300

> The patch from Wei Yang is a designed fix to a regression introduced
> by earlier commit of him. Jack added a fix to the resource
> management which we got from IBM.
> 
> Let's get that into 3.16-rc1 1st and later see to what stable
> version/s this should go.

Series applied to net-next, thanks.
