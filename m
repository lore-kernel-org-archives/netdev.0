From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: remove unsed variable in __mkroute_input
Date: Thu, 09 Jul 2015 21:34:49 -0700 (PDT)
Message-ID: <20150709.213449.1737729563721822785.davem@davemloft.net>
References: <1436413595-21154-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbGJEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:34:50 -0400
In-Reply-To: <1436413595-21154-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Thu,  9 Jul 2015 12:46:35 +0900

> flags local variable in __mkroute_input is not used as a variable.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Applied, thank you.
