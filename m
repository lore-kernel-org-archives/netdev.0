From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: add change MTU support
Date: Thu, 09 Jul 2015 00:31:35 -0700 (PDT)
Message-ID: <20150709.003135.1668058882729062782.davem@davemloft.net>
References: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbGIHbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 03:31:37 -0400
In-Reply-To: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed,  8 Jul 2015 16:06:47 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Implement ndo_change_mtu: on MTU change, reallocate Rx ring bufs and signal
> HW of new port MTU value.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks Scott.
