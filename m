From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: replace fixed stack allocation with
 dynamic allocation
Date: Mon, 16 Mar 2015 15:57:02 -0400 (EDT)
Message-ID: <20150316.155702.301802506038698308.davem@davemloft.net>
References: <1426485886-61607-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933757AbbCPT5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:57:05 -0400
In-Reply-To: <1426485886-61607-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 15 Mar 2015 23:04:46 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> In hast to fix some sparse warning, I hard-coded a fix-sized array on the stack
> which is probably too big for kernel standards.  Fix this by converting array
> to dynamic allocation.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks.
