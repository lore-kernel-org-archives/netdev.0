From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: allow routes to be configured with
 expire values
Date: Tue, 08 Dec 2015 22:56:20 -0500 (EST)
Message-ID: <20151208.225620.67864748611461829.davem@davemloft.net>
References: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449585464.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbLID4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:56:22 -0500
In-Reply-To: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449585464.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  8 Dec 2015 22:37:44 +0800

> Add the support for adding expire value to routes,  requested by
> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
> wants it too.
> 
> add it by using the field rta_expires of rta_cacheinfo
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Fix your outgoing patch emails, the From: field doesn't have your
full name in it so the commit AUTHOR fields look terrible.
