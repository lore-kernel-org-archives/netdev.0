From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] rocker: use netdev_err after
 register_netdev
Date: Thu, 06 Aug 2015 21:48:23 -0700 (PDT)
Message-ID: <20150806.214823.1691899568866315487.davem@davemloft.net>
References: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
	<1438666278-35614-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbHGEs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 00:48:28 -0400
In-Reply-To: <1438666278-35614-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon,  3 Aug 2015 22:31:18 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> After successful register_netdev, we can use netdev_err rather the more
> generic dev_err.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
