From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] rocker: NULL port if port probe fails
Date: Thu, 06 Aug 2015 21:48:11 -0700 (PDT)
Message-ID: <20150806.214811.2242347329783863149.davem@davemloft.net>
References: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbbHGEsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 00:48:31 -0400
In-Reply-To: <1438666278-35614-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon,  3 Aug 2015 22:31:17 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Set port to NULL if port probe fails so we don't try to remove partially
> initialized port on port probe err cleanup path.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
