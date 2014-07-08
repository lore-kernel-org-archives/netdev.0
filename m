From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: Fix do_one_broadcast() prototype.
Date: Mon, 07 Jul 2014 20:53:03 -0700 (PDT)
Message-ID: <20140707.205303.384926260669542226.davem@davemloft.net>
References: <1404238655-9762-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaGHDxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 23:53:06 -0400
In-Reply-To: <1404238655-9762-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Tue,  1 Jul 2014 21:17:35 +0300

> This patch changes the prototype of the do_one_broadcast() method so that it will return void.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thank you.
