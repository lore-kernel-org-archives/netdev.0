From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/3] switchdev: fix: pass correct obj size
 when deferring obj add
Date: Fri, 23 Oct 2015 06:32:38 -0700 (PDT)
Message-ID: <20151023.063238.1951994180447634714.davem@davemloft.net>
References: <1445570717-40780-1-git-send-email-sfeldma@gmail.com>
	<1445570717-40780-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbJWNQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:16:09 -0400
In-Reply-To: <1445570717-40780-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 22 Oct 2015 20:25:16 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Fixes: 4d429c5dd ("switchdev: introduce possibility to defer obj_add/del")
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
